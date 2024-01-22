% Цифровая обработка изображений
% Лабораторная №1

clc;
clear all;

% 1, 2
img_path = '.\lab_1.jpg';
image = imread(img_path);

img_size = size(image);
img_width = img_size(2);
img_height = img_size(1);

set_width = 800;
set_height = 800;

if img_width > set_width || img_height > set_height
    disp('Размер изображения больше заданного размера. Изменение размера...');
    [height, width, ~] = size(image);
    min_size = min(height, width);
    crop_size = min_size - 1;
    crop_x = floor((width - crop_size) / 2);
    crop_y = floor((height - crop_size) / 2);
    cropped_img = imcrop(image, [crop_x, crop_y, crop_size, crop_size]);
    image = imresize(cropped_img, [set_height, set_width]);
    disp('Изменение размера завершено.');
else
    disp(['Размер изображения соответствует допустимому, не более ', num2str(set_width), 'x', num2str(set_height)]);
end

% 3
imshow(image);
pause;

% 4
path = './DIP/Lab_1/';
path_jpg = './DIP/Lab_1/lab_1.jpg';
if ~isfolder(fileparts(path))
    mkdir(fileparts(path));
end

imwrite(image, path_jpg);
disp(['Изображение сохранено в формате jpg по пути: ', path_jpg]);

% 5
path_png = './DIP/Lab_1/lab_1.png';
imwrite(image, path_png);
disp(['Изображение сохранено в формате png по пути: ', path_png]);

% 6
info_jpg = dir(path_jpg);
info_png = dir(path_png);

disp('Информация о сохраненных файлах:');
disp(['Файл jpg: ', info_jpg.name]);
disp(['Размер файла jpg: ', num2str(info_jpg.bytes), ' байт']);
disp(['Файл png: ', info_png.name]);
disp(['Размер файла png: ', num2str(info_png.bytes), ' байт']);

% 7
info_jpg = imfinfo(path_jpg);
info_png = imfinfo(path_png);

% Расчет степени сжатия для формата jpg, png
Ks_jpg = ((info_jpg.Width * info_jpg.Height * info_jpg.BitDepth) / 8) / info_jpg.FileSize;
Ks_png = ((info_png.Width * info_png.Height * info_png.BitDepth) / 8) / info_png.FileSize;

disp('Степень сжатия изображений:');
disp(['Формат jpg: ', num2str(Ks_jpg)]);
disp(['Формат png: ', num2str(Ks_png)]);

if Ks_jpg > Ks_png
    disp('Изображение в формате jpg имеет большую степень сжатия');
    format = 'png';
elseif Ks_jpg < Ks_png
    disp('Изображение в формате png имеет большую степень сжатия');
    format = 'jpg';
else
    disp('Степень сжатия изображений в форматах jpg и png одинакова');
    format = 'png';
end

% 8
if size(image, 3) == 3
    gray_img = rgb2gray(image);
else
    gray_img = image;
end
imshow(gray_img);
pause;

out_path_gr = ['./DIP/Lab_1/gray_image', '.', format];
imwrite(gray_img, out_path_gr);

% 9
thresholds = [0.25, 0.5, 0.75];

logical_dir = './DIP/Lab_1/Logical/';
if ~isfolder(logical_dir)
    mkdir(logical_dir);
end

for i = 1:length(thresholds)
    bin_img = imbinarize(gray_img, thresholds(i));
    imshow(bin_img);
    title(['Двоичное изображение с порогом = ', num2str(thresholds(i))]);
    pause;

    out_path = ['./DIP/Lab_1/Logical/bin_img_', num2str(thresholds(i)), '.', num2str(format)];
    imwrite(bin_img, out_path);
end

% 10
bitplane_dir = './DIP/Lab_1/BitPlane/';
if ~isfolder(bitplane_dir)
    mkdir(bitplane_dir);
end

bit_img = im2uint8(gray_img);

bit_planes = false([info_png.Height, info_png.Width, 8]);
for i = 1:8
    bit_planes(:, :, i) = bitget(bit_img, i);
end

for i = 1:8
    bin_img = logical(bit_planes(:, :, i));
    imshow(bin_img);
    title(['Bit Plane ', num2str(i)]); % Добавление подписи к графику
    pause;

    out_path = [bitplane_dir, 'bit_plane_', num2str(i), '.', num2str(format)];
    imwrite(bin_img, out_path);
end

% 11
discret_dir = './DIP/Lab_1/Discret/';
if ~isfolder(discret_dir)
    mkdir(discret_dir);
end

kernel_sizes = [5, 10, 20, 50];

for i = 1:length(kernel_sizes)
    kernel_size = kernel_sizes(i);
    discret_img = mat2gray(blkproc(gray_img, [kernel_size kernel_size], 'mean2(x) * ones(size(x))'));

    imshow(discret_img);
    title(['Дискретизацию полутонового изображения с ядром ', num2str(kernel_size), 'x', num2str(kernel_size)]); 
    pause;

    out_path = [discret_dir, 'discret_img_', num2str(kernel_size), '.', num2str(format)];
    imwrite(discret_img, out_path);
end

% 12
quantiz_dir = './DIP/Lab_1/Quantiz/';
if ~isfolder(quantiz_dir)
    mkdir(quantiz_dir);
end

quant_levels = [4, 16, 32, 64, 128];

for i = 1:length(quant_levels)
    quant_level = quant_levels(i);
    quant_img = mat2gray(imquantize(gray_img, linspace(0, 255, quant_level)));

    imshow(quant_img);
    title(['Квантование по уровню ', num2str(quant_level)]); 
    pause;

    out_path = [quantiz_dir, 'quant_img_', num2str(quant_level), '.', num2str(format)];
    imwrite(quant_img, out_path);
end

% 13
crop_dir = './DIP/Lab_1/Crop/';
if ~isfolder(crop_dir)
    mkdir(crop_dir);
end

crop_size = 100;

crop_x = floor((size(gray_img, 2) - crop_size) / 2);
crop_y = floor((size(gray_img, 1) - crop_size) / 2);
crop_img = imcrop(gray_img, [crop_x, crop_y, crop_size-1, crop_size-1]);

imshow(crop_img);
title('Вырезанная область');
pause;

out_path = fullfile(crop_dir, ['crop_img.', format]);
imwrite(crop_img, out_path);

% 14
p1 = [21, 17];
p2 = [15, 11];
p3 = [19, 88];

N1 = gray_img(p1(2)-1:p1(2)+1, p1(1)-1:p1(1)+1);
disp('Значения четырех соседей пикселя p1:');
disp(['   ', num2str(N1(1,1)), '   0   ', num2str(N1(1,3))]);
disp(['   0   ', num2str(N1(2,2)), '   0']);
disp(['   ', num2str(N1(3,1)), '   0   ', num2str(N1(3,3))]);

N2 = gray_img(p2(2)-1:p2(2)+1, p2(1)-1:p2(1)+1);

disp('Значения четырех соседей пикселя p2:');
disp(['   0   ', num2str(N2(1,2)), '   0']);
disp(['   ', num2str(N2(2,1)), '  ', num2str(N2(2,2)), '   ', num2str(N2(2,3))]);
disp(['   0   ', num2str(N2(3,2)), '   0']);

N3 = gray_img(p3(2)-1:p3(2)+1, p3(1)-1:p3(1)+1);
disp('Значения восьмерки соседей пикселя p3:');
disp(N3);

% 15
mean_int = mean(gray_img(:));
disp(['Средний уровень яркости на изображении: ', num2str(mean_int)]);

% 16
output_dir = './DIP/Lab_1/Marks/';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

marked_img = gray_img;

corner_x = 10;
corner_y = 10;
center_x = round(size(gray_img, 2) / 2);
center_y = round(size(gray_img, 1) / 2);

positions = [center_x-10 center_y-10; corner_x corner_y; 
             size(gray_img, 2)-30 corner_y; corner_x size(gray_img, 1)-30; 
             size(gray_img, 2)-30 size(gray_img, 1)-30];
colors = cell(5, 1);

for i = 1:5
    if i == 1
        region = marked_img(center_y-9:center_y+10, center_x-9:center_x+10);
    else
        region = marked_img(positions(i, 2):positions(i, 2)+19, positions(i, 1):positions(i, 1)+19);
    end
    
    mean_value = mean(mean(region));
    
    if mean_value < 128
        colors{i} = 'white';
    else
        colors{i} = 'black';
    end
    
    marked_img = insertShape(marked_img, 'FilledRectangle', [positions(i, 1) positions(i, 2) 20 20], 'Color', colors{i}, 'Opacity', 1);
end

imshow(marked_img);

out_path = fullfile(output_dir, ['marked_img.', format]);
imwrite(marked_img, out_path);
