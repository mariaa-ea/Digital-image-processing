% Цифровая обработка изображений
% Лабораторная №2

clc;
clear all;

% 1
M = 800; 
N = 800; 
empty_img = uint8(zeros(M, N));

% 2
A = 0.1; 
B = 20; 
noise = imnoise2('gaussian', M, N, A, B); 
img_noisy = imadd(empty_img, uint8(noise)); 

% 3
path = './DIP/Lab_2/';
if ~isfolder(path)
    mkdir(path);
end

histogram(noise(:), 'BinWidth', 1); 
xlabel('Интенсивность пикселей');
ylabel('Частота');
title('Гистограмма распределения шума');
pause;

saveas(gcf, fullfile(path, 'histogram.png'));
imwrite(img_noisy, fullfile(path, 'img_noisy.png'));

imshow(img_noisy);
title('Изображение с шумом');
pause;

% 4
% Объект 1 - прямоугольник
center_x = round(size(empty_img, 2)/2); 
center_y = round(size(empty_img, 1)/2); 
rect_width = 200; 
rect_height = 100; 
rect_x1 = center_x - round(rect_width/2); 
rect_x2 = center_x + round(rect_width/2); 
rect_y1 = center_y - round(rect_height/2);
rect_y2 = center_y + round(rect_height/2); 
img_obg_1 = img_noisy; 
img_obg_1(rect_y1:rect_y2, rect_x1:rect_x2) = 255; 

imshow(img_obg_1);
title('Объект 1');
pause;
imwrite(img_obg_1, fullfile(path, 'img_obg_1.png'));

% 5
img_scaled_nn = imresize(img_obg_1, 2, 'nearest');
imshow(img_scaled_nn);
title('Масштабирование (метод ближайшего соседа)');
pause;

img_scaled_bilinear = imresize(img_obg_1, 0.5, 'bilinear');
imshow(img_scaled_bilinear);
title('Масштабирование (билинейная интерполяция)');
pause;

imwrite(img_scaled_nn, fullfile(path, 'scaled_nn.png'));
imwrite(img_scaled_bilinear, fullfile(path, 'scaled_bilinear.png'));

% 6
new_img = img_noisy;
indent = 20;

% Объект 2 - прямоугольный треугольник
triangle_width = 120; 
triangle_height = 120; 
triangle_x = (indent+1):(indent+triangle_width);
triangle_y = (indent+1):(indent+triangle_height); 
x_tr = [triangle_x(end), triangle_x(1), triangle_x(end)]; 
y_tr = [triangle_y(1), triangle_y(end), triangle_y(end)]; 
tri = [1 2 3];
tr = poly2mask(x_tr, y_tr, size(new_img, 1), size(new_img, 2));
tr_contour = bwperim(tr, 8); 
new_img(tr_contour) = 255; 

% Объект 3 - белый круг
circle_radius = 50; 
circle_center_x = size(new_img, 2) - circle_radius - indent; % X-координата центра круга с отступом 20 пикселей
circle_center_y = size(new_img, 1) - circle_radius - indent; % Y-координата центра круга с отступом 20 пикселей
[x, y] = meshgrid(1:size(new_img, 2), 1:size(new_img, 1));
circle_mask = sqrt((x - circle_center_x).^2 + (y - circle_center_y).^2) <= circle_radius; % Маска круга
new_img(circle_mask) = 255; % Применение маски круга

imshow(new_img);
title('Новое изображение с объектами 2 и 3');
pause;
imwrite(new_img, fullfile(path, 'new_img.png'));

% 7
flipud_img = flipud(new_img);
imwrite(flipud_img, fullfile(path, 'flipud_img.png'));

imshow(flipud_img);
title('Зеркальное отражение по горизонтали');
pause;

% 8
fliplr_img = fliplr(flipud_img);
imwrite(fliplr_img, fullfile(path, 'fliplr_img.png'));

imshow(fliplr_img);
title('Зеркальное отражение по вертикали');
pause;

% 9
rotated_img = imrotate(fliplr_img, -45);
imwrite(rotated_img, fullfile(path, 'rotated_img.png'));

imshow(rotated_img);
title('Поворот изображения на 45° по часовой стрелке');
pause;

% 10
rotated_back_img = imrotate(rotated_img, 45);
imwrite(rotated_back_img, fullfile(path, 'rotated_back_img.png'));

imshow(rotated_back_img);
title('Поворот изображения на 45° против часовой стрелки');
pause;

% 11
path = '.\DIP\Lab_2\Fon\';
if ~isfolder(path)
    mkdir(path);
end

background_img = imread('.\pict.jpg');

% 12
background_height = size(background_img, 1);
background_width = size(background_img, 2);

crop_size = 800;
crop_x = floor((background_width - crop_size) / 2) + 1;
crop_y = floor((background_height - crop_size) / 2) + 1;

cropped_img = background_img(crop_y:crop_y+crop_size-1, crop_x:crop_x+crop_size-1, :);

imshow(cropped_img);
title('Вырезанный участок изображения фона');
pause;
imwrite(cropped_img, fullfile(path, 'cropped_img.png'));

% 13
cropped_img_dark = cropped_img / 4;
imshow(cropped_img_dark);
title('Уменьшили яркость изображения в 4 раза');
pause;
imwrite(cropped_img_dark, fullfile(path, 'cropped_img_dark.png'));

% 14
if size(image, 3) == 3
    cropped_img_gr = rgb2gray(cropped_img_dark);
else
    cropped_img_gr = cropped_img_dark;
end
cropped_img_gr(tr_contour) = 255; 
cropped_img_gr(circle_mask) = 255;
noisy_img = imnoise(cropped_img_gr, 'gaussian', 0.05);

imshow(noisy_img);
title('Новое полутоновое изображение с шумом, 2 объекта');
pause;
imwrite(noisy_img, fullfile(path, 'noisy_img.png'));

% 15
neg_img = imcomplement(noisy_img);

imshow(neg_img);
title('"Негативное" изображение');
pause;
imwrite(neg_img, fullfile(path, 'neg_img.png'));

% 16
if size(cropped_img, 3) == 3
    new_cropped_img_gr = rgb2gray(cropped_img);
else
    new_cropped_img_gr = cropped_img;
end

new_cropped_img_gr(rect_y1:rect_y2, rect_x1:rect_x2) = 255; 
new_noisy_img = imnoise(new_cropped_img_gr, 'gaussian', 0.05);

imshow(new_noisy_img);
title('Новое полутоновое изображение с шумом, 1 объект');
pause;
imwrite(new_noisy_img, fullfile(path, 'new_noisy_img.png'));

% 17
diff_img = imabsdiff(noisy_img, new_noisy_img);

imshow(diff_img);
title('Разность двух изображений');
pause;
imwrite(diff_img, fullfile(path, 'diff_img.png'));
