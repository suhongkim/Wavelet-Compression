function [imgC, horDs, verDs] = ternary_decomp(imgF, level, isInt, visible)
% ternary_decomp : 1D horizontal T -> 1D vertical T for 3^n X 3^n

% conver to grayscale if not
if size(imgF,3)~=1, imgF = rgb2gray(imgF); end 
% resize the image : 3^n X 3^n 
max_n = floor(log(size(imgF, 2))/log(3)); 
level = min(level, max_n); 
imgF = imresize(imgF, [3^max_n, 3^max_n]); 
% convert to double for sparse matrix
imgF = double(imgF);

% decomp loop
horDs = cell(1, level); 
verDs = cell(1, level); 
img = imgF;
for n = max_n:-1:max_n-level+1
    % define the sparse matrix for A, B based on input image pixel
    % A matrix(Coarse) for decomposition 
    i = zeros(1, 3^n); 
    j = zeros(1, 3^n); 
    v = zeros(1, 3^n); 
    i(1:3^n) = reshape([1:3^(n-1); 1:3^(n-1); 1:3^(n-1)], 1, []); %111222333...
    j(1:3^n) = 1:3^n; 
    v(1:3^n) = 1/3;
    A = sparse(i,j,v); 
    % B matrix (detail) for decomposition
    clear i j v; 
    i = zeros(1, 2*3^n); 
    j = zeros(1, 2*3^n); 
    v = zeros(1, 2*3^n); 
    %odd row 111333555...
    i(1:3^n) = reshape([1:2:2*3^(n-1); 1:2:2*3^(n-1); 1:2:2*3^(n-1)], 1, []); 
    j(1:3^n) = 1:3^n; 
    %even row 222444666...
    i(1+3^n:2*3^n) = reshape([2:2:2*3^(n-1); 2:2:2*3^(n-1); 2:2:2*3^(n-1)], 1, []); 
    j(1+3^n:2*3^n) = 1:3^n;
    if isInt
        v(1:3^n) = repmat([1 -1 0], 1, 3^(n-1));
        v(1+3^n:2*3^n) = repmat([0 -1 1], 1, 3^(n-1)); 
        B = sparse(i,j,v);
    else
        v(1:3^n) = 1/3 + repmat([-1 0 0], 1, 3^(n-1));
        v(1+3^n:2*3^n) = 1/3 + repmat([0 -1 0], 1, 3^(n-1)); 
        B = sparse(i,j,v);
    end
        

    % horizontal decomp wrt rows  
    imgH = zeros(3^n, 3^(n-1)); 
    horD = zeros(3^n, 2*3^(n-1)); 
    for r = 1:3^n
        rowF = img(r,:); 
        if isInt
            rowC = transpose(floor(A*rowF' + 1e-5));
            rowD = transpose(B*rowF'); 
        else
            rowC = transpose(A*rowF');
            rowD = transpose(B*rowF'); 
        end
        imgH(r, :) = rowC;
        horD(r, :) = rowD; 
    end
    
    % vertical decomp wrt cols
    imgC = zeros(3^(n-1), 3^(n-1));
    verD = zeros(2*3^(n-1), 3^(n-1));
    for c = 1:3^(n-1)
        colF = imgH(:,c);
        if isInt
            colC = floor(A*colF + 1e-5); 
            colD = B*colF; 
        else
            colC = A*colF; 
            colD = B*colF; 
        end
        imgC(:, c) = colC; 
        verD(:, c) = colD; 
    end
    
    % save image 
    fig = figure('visible', visible); 
    subplot(1, 2, 1); imshow(uint8(img)); title(strcat('input: ', 'n=',int2str(n)));
    subplot(1, 2, 2); imshow(uint8([[imgC;verD] horD]));title(strcat('onput: ', 'n=',num2str(n-1)));
    saveas(fig, strcat('./output/tdecomp_', int2str(n),'.png'));
    %imwrite(uint8(imgC), strcat('./output/tdecomp_out', int2str(n),'.png'));
    
    % update Detail output
    if isInt
        imgC = uint8(imgC); %0<=imgC<=255 : uint8
        horDs{n-(max_n-level)} = int16(horD); % -255 <= f0-f1 <= 255
        verDs{n-(max_n-level)} = int16(verD); % -255 <= f0-f1 <= 255
    else
        horDs{n-(max_n-level)} = horD; 
        verDs{n-(max_n-level)} = verD;
    end
    
    % update image input
    img = double(imgC); 
end



