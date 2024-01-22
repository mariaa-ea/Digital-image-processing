% Цифровая обработка изображений
% Лабораторная №5

% 1
clc;
clear all;

I = imread('.\lab_5_defected_image.jpg');
I1 = im2bw(I);
square = strel('square', 20);
I2 = imopen(I1, square);
I3 = imclose(I1, square);
I4 = imclose(I2, square);

subplot(2,2,1); 
imshow(I1); 
title('Оригинал');

subplot(2,2,2); 
imshow(I2); 
title('Imopen');

subplot(2,2,3); 
imshow(I3);  
title('Imclose');

subplot(2,2,4); 
imshow(I4); 
title('Imopen & imclose'); 

path = '.\Results\1\';
if ~isfolder(fileparts(path))
    mkdir(fileparts(path));
end

saveas(gcf, fullfile(path, 'result_of_morphological_processing.png'));
pause;

% 2
clc;
clear all;

I = imread('.\lab_5_border.jpg');
I1 = im2bw(I);
I2 = ~I1;

subplot(2,2,1); 
imshow(I2); 
title('Оригинал');

BW2 = bwmorph(I1, 'erode', 10);
subplot(2,2,2); 
imshow(BW2); 
title('Результат операции "erode"');

BW2 = bwmorph(BW2, 'thicken', Inf);
subplot(2,2,3); 
imshow(BW2); 
title('Результат операции "thicken"');

Inew = ~(I1&BW2);
subplot(2,2,4); 
imshow(Inew); 
title('Итог'); 

path = '.\Results\2\';
if ~isfolder(fileparts(path))
    mkdir(fileparts(path));
end

saveas(gcf, fullfile(path, 'lab_5_border_sum.jpg'));
pause;

B = strel('disk', 1);
I3 = imdilate(Inew, B);
C = I3 & ~Inew;
subplot(1,1,1); 
imshow(C); 
title('Результат выделения границ'); 

saveas(gcf, fullfile(path, 'result_of_border_separation.png'));
pause;

% 3
clc;
clear all;

rgb = imread ('.\lab_5.jpeg');
A = rgb2gray(rgb);
B = strel('disk', 23);
C = imerode(A, B);
Cr = imreconstruct(C, A);
Crd = imdilate(Cr, B);
Crdr = imreconstruct(imcomplement(Crd), imcomplement(Cr));
Crdr = imcomplement(Crdr);

imshow(Crdr);
title('Отфильтрованное изображение')

path = '.\Results\3\';
if ~isfolder(fileparts(path))
    mkdir(fileparts(path));
end

saveas(gcf, fullfile(path, 'filtered_image.png'));
pause;

fgm = imregionalmax(Crdr);
A2 = A;
A2(fgm) = 255;

B2 = strel(ones(5, 5));
fgm = imclose(fgm, B2);
fgm = imerode(fgm, B2);
fgm = bwareaopen(fgm, 75);

A3 = A;
A3(fgm) = 255;

bw = imbinarize(Crdr);
D = bwdist(bw);
L = watershed(D);
bgm = L == 0;

subplot(2, 2, 1);
imshow(bw);
title('Бинаризованное изображение');

subplot(2, 2, 2);
imshow(D, []);
title('Расстояние');

subplot(2, 2, 3);
imshow(L);
title('Результат алгоритма водораздела');

subplot(2, 2, 4);
imshow(bgm);
title('Маркеры фона');

saveas(gcf, fullfile(path, 'watershed_algorithm.png'));
pause;

hy = fspecial('sobel');
hx = hy';
Ay = imfilter(im2double(A), hy, 'replicate');
Ax = imfilter(im2double(A), hx, 'replicate');
grad = sqrt(Ax.^2 + Ay.^2);

subplot(1, 2, 1); 
imshow(grad); 
title('Исходное градиентное представление');

grad = imimposemin(grad, bgm | fgm );
subplot(1, 2, 2); 
imshow(grad); 
title('Модифицированное градиентное представление'); 

saveas(gcf, fullfile(path, 'gradient_representation.png'));
pause;

L = watershed(grad);
A4 = A;
A4(imdilate(L == 0, ones(3, 3)) | bgm | fgm) = 255;
Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');

subplot(1, 2, 1);
imshow(A4);
title('Сегментированное изображение');

subplot(1, 2, 2);
imshow(Lrgb);
title('Результат алгоритма управляемого водораздела');

saveas(gcf, fullfile(path, 'result_of_watershed_algorithm.png'));
pause;
