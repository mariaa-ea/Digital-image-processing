% Цифровая обработка изображений
% Лабораторная №4

clc;
clear all;

% 1
img_path = '.\lab_4.jpg';

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

if size(image, 3) == 3
    gr_img = rgb2gray(image);
else
    gr_img = image;
end

imshow(gr_img);
title('Исходное полутоновое изображение');
pause;

fft_img = fft2(gr_img);
fft_img_shift = fftshift(fft_img);
fft_img_mag = abs(fft_img_shift);
fft_img_mag_log = log(fft_img_mag + 1);

subplot(1, 2, 1);
imshow(gr_img);
title('Исходное изображение');
subplot(1, 2, 2);
imshow(fft_img_mag_log, []);
title('Фурье-спектр изображения');
pause;

path = './DIP/Lab_4/';
if ~isfolder(fileparts(path))
    mkdir(fileparts(path));
end

saveas(gcf, fullfile(path, 'original_and_fft_spectrum.png'));
disp(['Исходное изображение сохранено по пути: ', path]);

% 2
D0_values = [5, 10, 50, 250];

for i = 1:length(D0_values)
    D0 = D0_values(i);
    
    [rows, cols] = size(gr_img);
    center_row = floor(rows/2) + 1;
    center_col = floor(cols/2) + 1;
    [X, Y] = meshgrid(1:cols, 1:rows);
    distance = sqrt((X - center_col).^2 + (Y - center_row).^2);
    H = double(distance <= D0);
    
    filtered_fft_img_shift = fft_img_shift .* H;
    filtered_fft_img = ifftshift(filtered_fft_img_shift);
    filtered_img = uint8(abs(real(ifft2(filtered_fft_img))));
    
    subplot(2, 2, i);
    imshow(filtered_img, []);
    title(['Идеальный ФНЧ (D0 = ', num2str(D0), ')']);
end

path = './DIP/Lab_4/Low/Ideal/';
if ~isfolder(path)
    mkdir(path);
end

saveas(gcf, fullfile(path, 'filtered_image_ideal_LPF.png'));
pause;

n = 2;
for i = 1:length(D0_values)
    D0 = D0_values(i);
    H = 1 ./ (1 + (distance ./ D0).^(2*n));
    
    filtered_fft_img_shift = fft_img_shift .* H;
    filtered_fft_img = ifftshift(filtered_fft_img_shift);
    filtered_img = uint8(abs(real(ifft2(filtered_fft_img))));

    subplot(2, 2, i);
    imshow(filtered_img, []);
    title(['ФНЧ - Баттерворт (D0 = ', num2str(D0), ')']);
end

path = './DIP/Lab_4/Low/Butter/';
if ~isfolder(path)
    mkdir(path);
end

saveas(gcf, fullfile(path, 'filtered_image_Butter_LPF.png'));
pause;

for i = 1:length(D0_values)
    D0 = D0_values(i);
    H = exp(-(distance.^2) ./ (2 * D0^2));
    
    filtered_fft_img_shift = fft_img_shift .* H;
    filtered_fft_img = ifftshift(filtered_fft_img_shift);
    filtered_img = uint8(abs(real(ifft2(filtered_fft_img))));

    subplot(2, 2, i);
    imshow(filtered_img, []);
    title(['ФНЧ - Gaussian (D0 = ', num2str(D0), ')']);
end

path = './DIP/Lab_4/Low/Gaus/';
if ~isfolder(path)
    mkdir(path);
end

saveas(gcf, fullfile(path, 'filtered_image_gaussian_LPF.png'));
pause;

% 3
for i = 1:length(D0_values)
    D0 = D0_values(i);
    H = double(distance > D0);
    
    filtered_fft_img_shift = fft_img_shift .* H;
    filtered_fft_img = ifftshift(filtered_fft_img_shift);
    filtered_img = uint8(abs(real(ifft2(filtered_fft_img))));
    
    subplot(2, 2, i);
    imshow(filtered_img, []);
    title(['Идеальный ФВЧ (D0 = ', num2str(D0), ')']);
end

path = './DIP/Lab_4/High/Ideal/';
if ~isfolder(path)
    mkdir(path);
end

saveas(gcf, fullfile(path, 'filtered_image_ideal_HPF.png'));
pause;

for i = 1:length(D0_values)
    D0 = D0_values(i);
    H = 1 ./ (1 + (D0 ./ distance).^(2*n));

    filtered_fft_img_shift = fft_img_shift .* H;
    filtered_fft_img = ifftshift(filtered_fft_img_shift);
    filtered_img = uint8(abs(real(ifft2(filtered_fft_img))));
   
    subplot(2, 2, i);
    imshow(filtered_img, []);
    title(['ФВЧ - Баттерворт (D0 = ', num2str(D0), ')']);
end

path = './DIP/Lab_4/High/Butter/';
if ~isfolder(path)
    mkdir(path);
end

saveas(gcf, fullfile(path, 'filtered_image_Butter_HPF.png'));
pause;

for i = 1:length(D0_values)
    D0 = D0_values(i);
    H = 1 - exp(-(distance.^2) ./ (2 * D0^2));
    
    filtered_fft_img_shift = fft_img_shift .* H;
    filtered_fft_img = ifftshift(filtered_fft_img_shift);
    filtered_img = uint8(abs(real(ifft2(filtered_fft_img))));

    subplot(2, 2, i);
    imshow(filtered_img, []);
    title(['ФВЧ - Gaussian (D0 = ', num2str(D0), ')']);
end

path = './DIP/Lab_4/High/Gaus/';
if ~isfolder(path)
    mkdir(path);
end

saveas(gcf, fullfile(path, 'filtered_image_gaussian_HPF.png'));
pause;
