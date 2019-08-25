function [imgF] = haar_reconst(imgC, horDs, verDs, level, isInt, visible)
% haar_reconst : 1D horizontal T <- 1D vertical T for 2^n X 2^n

% conver to grayscale if not
if size(imgC,3)~=1, imgC = rgb2gray(imgC); end 
% resize the image : 2^n X 2^n 
min_n = floor(log(size(imgC, 2))/log(2)); 
level = min(level, size(horDs,2)); 
imgC = imresize(imgC, [2^min_n, 2^min_n]); 
% convert to double for sparse matrix
imgC = double(imgC);

% decomp loop
img = imgC;
d_idx = 1;  %detail cell array index
for n = min_n: min_n+level-1
    % define the sparse matrix for P, Q based on input image pixel
    % P matrix(Fine) for reconstrunction 
    i = zeros(1, 2^(n+1)); 
    j = zeros(1, 2^(n+1)); 
    v = zeros(1, 2^(n+1)); 
    i(1:2^(n+1)) = 1:2^(n+1); 
    j(1:2^(n+1)) = reshape([1:2^n; 1:2^n], 1, []);  % 11223344....
    v(1:2^(n+1)) = 1; 
    P = sparse(i,j,v); 
    % Q matrix(Detail) for reconstrunction
    if isInt
        % for floor op (-sign should be after floor)
        v(1:2^(n+1)) = repmat([1/2 1/2], 1, 2^n); 
        Q_f = sparse(i,j,v); 
        % for leftover op 
        v(1:2^(n+1)) = repmat([1 0], 1, 2^n); 
        Q = sparse(i,j,v); 
    else
        v(1:2^(n+1)) = repmat([1 -1], 1, 2^n);
        Q = sparse(i,j,v); 
    end
    % reconstruction image
    imgH = zeros(2^(n+1), 2^n);  
    % vertical reconstruction wrt cols
    for c = 1:2^n
        colC = img(:,c);        % coarse img
        colD = double(verDs{d_idx}(:,c));   % coarse detail
        if isInt
            colF = P*colC - floor(Q_f*colD + 1e-5) + Q*colD; %Absolute
        else     
            colF = P*colC + Q*colD; 
        end
        imgH(:, c) = colF; 
    end
    imgF = zeros(2^(n+1));
    % horizontal reconstruction wrt rows
    for r = 1:2^(n+1)
        rowC = imgH(r,:);
        rowD = double(horDs{d_idx}(r,:));
        if isInt
            rowF = transpose(P*rowC' - floor(Q_f*rowD' + 1e-5) + Q*rowD');
        else
            rowF = transpose(P*rowC' + Q*rowD');
        end
        imgF(r, :) = rowF; 
    end
    
    % save image 
    fig = figure('visible',visible); 
    subplot(1, 2, 1); imshow(uint8([[img;verDs{d_idx}] horDs{d_idx}]));title(strcat('input: ', 'n=',num2str(n)));
    subplot(1, 2, 2); imshow(uint8(imgF)); title(strcat('output: ', 'n=',int2str(n+1)));
    saveas(fig, strcat('./output/hreconst_', int2str(n+1),'.png'));
    %imwrite(uint8(imgF), strcat('./output/hreconst_out', int2str(n),'.png'));
    
    % update output in non-int /int 
    if isInt, imgF = uint8(imgF); end
        
    % update image input
    img = double(imgF); % for sparse computation 
    d_idx = d_idx+1;
    
    
end



