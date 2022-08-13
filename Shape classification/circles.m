a = imread('100 (2).jpg');

c = rgb2gray(a);
% imhist(c)
[rows, cols] = size(c);
temp = zeros(rows, cols, 'uint8');

for i=1:1:rows
    for j= 1:1:cols
        if c(i,j) > 200
            temp(i,j) = 255;
        end
    end
end
flag = 0;
for i=1:30:rows-30
    for j= 1:30:cols-30
        M = temp(i:i+29, j:j+29);
        M(1:2, :) = 255;
        M(29:30, :) = 255;
        M(:, 1:2) = 255;
        M(:, 29:30) = 255;
        if flag<888
            subplot(30, 30, flag+1); imshow(M);
            flag = flag+1;
        end
        writematrix(M(:).','data.csv','WriteMode','append');
    end
end
