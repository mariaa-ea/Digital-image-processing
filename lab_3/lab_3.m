% Цифровая обработка изображений
% Лабораторная №3

clc;
clear all;

% 1
img_path = '.\lab_3.jpg';

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

path = './DIP/Lab_3/';
if ~isfolder(fileparts(path))
    mkdir(fileparts(path));
end

imshow(gr_img);
title('Исходное полутоновое изображение');
pause;

imwrite(gr_img, fullfile(path, 'gr_img.png'));

histogram(gr_img);
title('Гистограмма изображения');
pause;
saveas(gcf, fullfile(path, 'histogram.png'));

% 2
path = './DIP/Lab_3/Log/';
if ~isfolder(fileparts(path))
    mkdir(fileparts(path));
end

log_transformed_img = log(1 + im2double(gr_img));

imshow(log_transformed_img);
title('Логарифмическое преобразование');
pause;
imwrite(log_transformed_img, fullfile(path, 'log_transformed_img.png'));

histogram(log_transformed_img);
title('После логарифмического преобразования');
pause;
saveas(gcf, fullfile(path, 'log_histogram.png'));

% 3
path = './DIP/Lab_3/Degree/';
if ~isfolder(fileparts(path))
    mkdir(fileparts(path));
end

gamma_values = [0.1, 0.45, 1, 2, 3, 4, 5];
for i = 1:length(gamma_values)
    gamma = gamma_values(i);
    power_transformed_img = im2double(gr_img).^gamma;

    imshow((power_transformed_img));
    title(['Степенное преобразование (gamma = ', num2str(gamma), ')']);
    pause;
    imwrite((power_transformed_img), fullfile(path, ['power_transformed_img_', num2str(gamma), '.png']));

    histogram((power_transformed_img));
    title(['Гистограмма после степенного преобразования (gamma = ', num2str(gamma), ')']);
    pause;
    saveas(gcf, fullfile(path, ['power_histogram_', num2str(gamma), '.png']));
end

% 4
path = './DIP/Lab_3/Line_Contrast/';
if ~isfolder(path)
    mkdir(path);
end

points = [0, 0; 50, 255; 50, 0; 100, 255; 100, 0; 150, 255; 150, 0; 200, 255; 200, 0; 255, 255];
x = points(:, 1);
y = points(:, 2);

[h, w] = size(gr_img);
transformed_img = zeros(h, w);

for i = 1:h
    for j = 1:w
        if gr_img(i, j) <= x(1)
            transformed_img(i, j) = (y(1) / x(1)) * gr_img(i, j);
        elseif gr_img(i, j) >= x(end)
            transformed_img(i, j) = ((255 - y(end)) / (255 - x(end))) * (gr_img(i, j) - x(end)) + y(end);
        else
            for k = 1:length(x)-1
                if gr_img(i, j) >= x(k) && gr_img(i, j) < x(k+1)
                    transformed_img(i, j) = ((y(k+1) - y(k)) / (x(k+1) - x(k))) * (gr_img(i, j) - x(k)) + y(k);
                    break;
                end
            end
        end
    end
end

imwrite(transformed_img, fullfile(path, 'line_contrast_img.png'));
imshow(transformed_img);
title('Изображение после кусочно-линейного преобразования');
pause;

histogram(transformed_img);
title('Гистограмма после кусочно-линейного преобразования');
saveas(gcf, fullfile(path, 'line_contrast_histogram.png'));
pause;

% 5
path = './DIP/Lab_3/Equaliz/';
if ~isfolder(path)
    mkdir(path);
end

eq_img = histeq(gr_img);

imwrite(eq_img, fullfile(path, 'equalized_img.png'));
imshow(eq_img);
title('Изображение после эквализации гистограммы');
pause;

histogram(eq_img);
title('Гистограмма после эквализации изображения');
saveas(gcf, fullfile(path, 'equalized_histogram.png'));
pause;

% 6
path = './DIP/Lab_3/Filter/';
if ~isfolder(path)
    mkdir(path);
end

mask_sizes = [3, 15, 35];
for i = 1:length(mask_sizes)
    mask_size = mask_sizes(i);
    mask = ones(mask_size) / (mask_size^2);
    filtered_img = imfilter(gr_img, mask);

    imwrite(filtered_img, fullfile(path, ['filtered_img_', num2str(mask_size), '.png']));
    imshow(filtered_img);
    title(['Изображение после усредняющего фильтра (размер маски: ', num2str(mask_size), 'x', num2str(mask_size), ')']);
    pause;
end

% 7
path = './DIP/Lab_3/Filter/';
if ~isfolder(path)
    mkdir(path);
end

sharp_filter_1 = [0 1 0; 1 -4 1; 0 1 0];
sharp_filter_2 = [0 -1 0; -1 5 -1; 0 -1 0];
sharp_filter_3 = [-1 -1 -1; -1 9 -1; -1 -1 -1];

sharp_filters = {sharp_filter_1, sharp_filter_2, sharp_filter_3};

for i = 1:length(sharp_filters)
    sharp_img = imfilter(gr_img, sharp_filters{i});
    imwrite(sharp_img, fullfile(path, ['sharp_img_' num2str(i) '.png']));
    imshow(sharp_img);
    title(['Изображение после фильтра повышения резкости ' num2str(i)]);
    pause;
end

% 8
path = './DIP/Lab_3/Median/';
if ~isfolder(path)
    mkdir(path);
end

mask_sizes = [3, 9, 15];

for i = 1:length(mask_sizes)
    mask_size = mask_sizes(i);
    median_img = medfilt2(gr_img, [mask_size mask_size]);
    imwrite(median_img, fullfile(path, ['median_img_' num2str(mask_size) '.png']));
    imshow(median_img);
    title(['Изображение после медианного фильтра (размер маски: ' num2str(mask_size) 'x' num2str(mask_size) ')']);
    pause;
end

% 9
path = './DIP/Lab_3/Edge/';
if ~isfolder(path)
    mkdir(path);
end

roberts_img = edge(gr_img, 'roberts');
imwrite(roberts_img, fullfile(path, 'roberts_img.png'));
imshow(roberts_img);
title('Изображение после операции выделения границ методом Робертса');
pause;

prewitt_img = edge(gr_img, 'prewitt');
imwrite(prewitt_img, fullfile(path, 'prewitt_img.png'));
imshow(prewitt_img);
title('Изображение после операции выделения границ методом Превитта');
pause;

sobel_img = edge(gr_img, 'sobel');
imwrite(sobel_img, fullfile(path, 'sobel_img.png'));
imshow(sobel_img);
title('Изображение после операции выделения границ методом Собеля');
pause;

% 10
path = './DIP/Lab_3/Filter/';
if ~isfolder(path)
    mkdir(path);
end

variance = [0.05, 0.5, 0.75];

subplot_idx = 1;

for i = 1:length(variance)
    noisy_img = imnoise(gr_img, 'salt & pepper', variance(i));

    filtered_img_gauss = imgaussfilt(noisy_img);
    filtered_img_median = medfilt2(noisy_img);
    filtered_img_mean = imfilter(noisy_img, fspecial('average'));
    filtered_img_bilateral = imbilatfilt(noisy_img);
    filtered_img_harmonic = spfilt(noisy_img, 'chmean', 3, 3, 1.5);

    var_init = var(double(gr_img(:)));

    var_gauss = abs(var_init - var(double(filtered_img_gauss(:))));
    var_median = abs(var_init - var(double(filtered_img_median(:))));
    var_mean = abs(var_init - var(double(filtered_img_mean(:))));
    var_bilateral = abs(var_init - var(double(filtered_img_bilateral(:))));
    var_harmonic = abs(var_init - var(double(filtered_img_harmonic(:))));
 
    min_variance = min([var_gauss, var_median, var_mean, var_bilateral, var_harmonic]);

    if min_variance == var_gauss
        filtered_img = filtered_img_gauss;
        filter_name = 'Gaussian';
    elseif min_variance == var_median
        filtered_img = filtered_img_median;
        filter_name = 'Median';
    elseif min_variance == var_mean
        filtered_img = filtered_img_mean;
        filter_name = 'Mean';
    elseif min_variance == var_bilateral
        filtered_img = filtered_img_bilateral;
        filter_name = 'Bilateral';
    else
        filtered_img = filtered_img_harmonic;
        filter_name = 'Harmonic';
    end

    filtered_img_path = fullfile(path, ['filtered_image_', filter_name, '_', num2str(variance(i)), '.jpg']);
    imwrite(filtered_img, filtered_img_path);

    disp(['Дисперсия исходного изображения: ', num2str(var(double(gr_img(:))))]);
    disp(['Дисперсия отфильтрованного изображения (', filter_name, ' filter, variance = ', num2str(variance(i)), '): ', num2str(abs(min_variance - var_init))]);

    subplot(3, 3, subplot_idx);
    imshow(gr_img);
    title('Исходное изображение');

    subplot(3, 3, subplot_idx + 1);
    imshow(noisy_img);
    title(['Зашумленное изображение (variance = ', num2str(variance(i)), ')']);

    subplot(3, 3, subplot_idx + 2);
    imshow(filtered_img);
    title(['Отфильтрованное изображение (', filter_name, ' filter, variance = ', num2str(variance(i)), ')']);

    subplot_idx = subplot_idx + 3;
    pause;
end

saveas(gcf, fullfile(path, 'noisy_and_filtered_images.png'));
