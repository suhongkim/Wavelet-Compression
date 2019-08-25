function [imgC, horDs, verDs] = haar_decomp(imgF, level, isInt, visible)
% haar_decomp : 1D horizontal T -> 1D vertical T for 2^n X 2^n
% if isInt is true, this function should give Integer output 

% conver to grayscale if not
if size(imgF,3)~=1, imgF = rgb2gray(imgF); end 
% resize the image : 2^n X 2^n 
max_n = floor(log(size(imgF, 2))/log(2)); 
level = min(level, max_n); 
imgF = imresize(imgF, [2^max_n, 2^max_n]); 
% convert to double for sparse matrix
imgF = double(imgF);

% decomp loop
horDs = cell(1, level); 
verDs = cell(1, level); 
img = imgF;
for n = max_n:-1:max_n-level+1
    % define the sparse matrix for A, B based on input image pixel
    % A matrix(Coarse) for decomposition 
    i = zeros(1, 2^n); 
    j = zeros(1, 2^n); 
    v = zeros(1, 2^n); 
    i(1:2^(n-1)) = 1:2^(n-1); 
    j(1:2^(n-1)) = 1:2:2^n; 
    v(1:2^(n-1)) = 1/2; 
    i(2^(n-1)+1:2^n) = 1:2^(n-1); 
    j(2^(n-1)+1:2^n) = 2:2:2^n; 
    v(2^(n-1)+1:2^n) = 1/2;
    A = sparse(i,j,v); 
    % B matrix (detail) for decomposition
    if isInt
        v(1:2^(n-1)) = 1;
        v(2^(n-1)+1:2^n) = -1;
        B = sparse(i,j,v); 
    else
        v(1:2^(n-1)) = 1/2; 
        v(2^(n-1)+1:2^n) = -1/2;
        B = sparse(i,j,v); 
    end
    
    % horizontal decomp wrt rows  
    imgH = zeros(2^n, 2^(n-1)); 
    horD = zeros(2^n, 2^(n-1)); 
    for r = 1:2^n
        rowF = img(r,:); 
        if isInt, rowC = floor(transpose(A*rowF') + 1e-5); 
        else,     rowC = transpose(A*rowF'); end  
        rowD = transpose(B*rowF'); 
        imgH(r, :) = rowC;
        horD(r, :) = rowD;
    end
    % vertical decomp wrt cols
    imgC = zeros(2^(n-1), 2^(n-1));
    verD = zeros(2^(n-1), 2^(n-1));
    for c = 1:2^(n-1)
        colF = imgH(:,c);
        if isInt, colC = floor(A*colF + 1e-5); 
        else,     colC = A*colF; end
        colD = B*colF; 
        imgC(:, c) = colC; 
        verD(:, c) = colD;
    end
    % save image
    fig = figure('visible', visible); 
    subplot(1, 2, 1); imshow(uint8(img)); title(strcat('input: ', 'n=',int2str(n)));
    subplot(1, 2, 2); imshow(uint8([[imgC;verD] horD]));title(strcat('onput: ', 'n=',num2str(n-1)));
    saveas(fig, strcat('./output/hdecomp_', int2str(n),'.png'));
    %imwrite(uint8(imgC), strcat('./output/hdecomp_out', int2str(n),'.png'));
    
    % update output in non-int /int 
    if isInt 
        imgC = uint8(imgC); %0<=imgC<=255 : uint8
        horDs{n-(max_n-level)} = int16(horD); % -255 <= f0-f1 <= 255
        verDs{n-(max_n-level)} = int16(verD); % -255 <= f0-f1 <= 255
    else
        horDs{n-(max_n-level)} = horD; 
        verDs{n-(max_n-level)} = verD;
    end
    
    % update image input
    img = double(imgC);  % for sparse computation
    
end



