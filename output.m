fig = figure; 
set(gca, 'Visible', 'off');
subplot(3, 2, 1); 
imshow((g_img));title('original');
subplot(3, 2, 2); 
imshow(imread('./output/tdecomp_out5.png'));title('n=5');
subplot(3, 2, 3); 
imshow(imread('./output/tdecomp_out4.png'));title('n=4');
subplot(3, 2, 4); 
imshow(imread('./output/tdecomp_out3.png'));title('n=3');
subplot(3, 2, 5);
imshow(imread('./output/tdecomp_out2.png')); title('n=2');
subplot(3, 2, 6); 
imshow(imread('./output/tdecomp_out1.png'));title('n=1');

saveas(fig, 'twavelet_haar.png');

fig = figure; 
subplot(1, 2, 1); 
imshow(imread('./output/tdecomp_3.png'));title('Decomposition (n=3)');
subplot(1, 2, 2); 
imshow(imread('./output/treconst_3.png'));title('Reconstruction (n=3)');

saveas(fig, 'twavelet_haar_ex2.png');