clear;
imagefiles = dir('images/*.jpg');
n = length(imagefiles);
X = [];
M = 1280;
N = 960;
K = 15; %number of eigenvectors to keep
% 
% for i=1:n
%     imagename = strcat('images/', imagefiles(i).name);
%     tempimage = imread(imagename);
%     [b, a] = size(tempimage);
%     M = min(M, a);    
%     N = min(N, b);    
% end
for i=1:n
    imagename2 = strcat('images/', imagefiles(i).name);
    tempimage2 = imread(imagename2);
    tempimage2 = imresize(tempimage2, [M N]);
%     subplot(4, 5, i); imshow(tempimage2);
    tempimage2  = double(tempimage2); %change the data type to double
    X(:,i) = tempimage2(:);
    
end
% disp(size(X));
% PCA
mu = mean(X.').'; %compute the mean of images as vector
% imshow(uint8(reshape(mu, [M N 3])))
% disp(length(mu));
% 
meanNorm = X-mu;
cov = (meanNorm.'*meanNorm); % ; cov(meanNorm.')
[EvecX, EvalX] = eig(cov); % get eigenvalues and eigenvectors from covariance matrix

[EvalSorted, index] = sort(diag(EvalX), 'descend'); %Sort eigenvalues
SortedEval = EvecX(:, index);

pca = SortedEval(:,1:K).'; %Keep 'k' number of eigenvalues for further calculation

reduced = pca*meanNorm.';
% disp(['pca: ', num2str(size(pca))]);
% disp(['mean normalized: ', num2str(size(meanNorm))]);
% reduced = (OE)*(meanNorm);
% disp(['adjust: ', num2str(size(reduced))]);
adjust = pca.'*reduced;
original = adjust + mu.';
original = original.';

% 
% for  i=1:1:n
%     subplot(4, 5, i); imshow(uint8(reshape(original(:, i), [M N 3])));
% end

error = sum(sum(original - X))/(M*N*n);

disp(['error: ', num2str(error)])

imgfiles = dir('*.jpg');
imgname = imgfiles.name;
newimg = imread(imgname);
newimg = imresize(newimg, [M N]);
newimg  = double(newimg);
newimage = newimg(:)-mu;


disp(['reduced: ', num2str(size(reduced))]);
disp(['newimage: ', num2str(size(newimage))]);
% Y = reduced.';
% disp(['Y(i, :): ', num2str(size(Y(:, 1)))]);
minE =inf;
indE = -1;
dots=ones(1,K);
errors = ones(1, n);
proj= zeros(n, K);
for i=1:n
    for j=1:K
       proj(i,j) = dot(meanNorm(:,i), reduced(j,:).'); 
    end
end
for i=1:K
    dots(i) = dot(newimage, reduced(i, :).');
end
for i=1:n
   errors(i) = abs(sum(proj(i, :)-dots)); 
end

for i=1:n
   if errors(i)<minE
      minE = errors(i);
      indE=i;
   end
end
subplot(1, 2, 1); imshow(uint8(reshape(newimg, [M N 3])));
subplot(1, 2, 2); imshow(uint8(reshape(X(:, indE), [M N 3])));

