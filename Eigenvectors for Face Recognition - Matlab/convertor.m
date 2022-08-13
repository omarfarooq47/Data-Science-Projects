% imagefiles = dir('*.jpg');
% n = length(imagefiles);
% X = [];
% 
% for i=1:n
%     imagename = imagefiles(i).name;
%     tempimage = imresize(rgb2gray(imread(imagename)), [128, 128]);
%     tempimage = tempimage.';
%     imwrite(tempimage, strcat(imagefiles(i).name, '.tif'));
%     subplot(4, 5, i); imshow(tempimage);
%     tempimage  =double(tempimage); %change the data type to double
%     X(:,i) = tempimage(:).';
%     
%     
% end
% disp(size(X));
clear;
imagefiles = dir('*.jpg');
n = length(imagefiles);
newimage = {};

disp(n);
for i=1:n
    imagename = imagefiles(i).name;
    tempimage = imread(imagename);
    tempimage = imrotate(tempimage, -90, 'nearest', 'loose');
    imwrite(tempimage, strcat('images/', imagefiles(i).name, '.jpg'));
    subplot(2, 3, i); imshow(tempimage);
    
end