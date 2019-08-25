%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Wavelet Compression                %
%               - Suhong Kim -                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear all; close all; 
if isfolder('./output') ~= 1, mkdir('./output'); end 
g_img = imread('moon.tif'); 

%% Float/Integer Binary Haar Wavelet 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
level = inf; % inf is max level
isInt = true; % Integer  
visible = 'off'; % plot 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Binary Haar starts ...');
[c_img, h, v] = haar_decomp(g_img, level, isInt, visible);
f_img = haar_reconst(c_img, h, v, level, isInt, visible);  
disp('Binary Haar is Done!(All images are saved)'); 

% check output  
g_img = imresize(g_img, size(f_img));
checkM = (g_img == uint8(f_img)); 
if(size(f_img,1)*size(f_img,2) == sum(checkM(:)))
    disp('-->Input and Output are same!'); 
end


%% Float/Integer Ternary Wavelet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
level = inf; % inf is max level
isInt = true; % Integer  
visible = 'off'; % plot 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Ternary Wavelet starts ...');
[c_img, h, v] = ternary_decomp(g_img, level, isInt, visible);
f_img = ternary_reconst(c_img, h, v, level, isInt, visible);  
disp('Ternary Wavelet is Done!(All images are saved)'); 

% check output
g_img = imresize(g_img, size(f_img));
checkM = (g_img == uint8(f_img)); 
if(size(f_img,1)*size(f_img,2) == sum(checkM(:)))
    disp('-->Input and Output are same!'); 
end