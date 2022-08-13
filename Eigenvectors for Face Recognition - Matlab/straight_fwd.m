imagefiles = dir('imagesBW/*.tif');
n = length(imagefiles);
X = [];
M = 64;
N = 64;
K = 20; %number of eigenvectors to keep

for i=1:n
    imagename = strcat('imagesBW/', imagefiles(i).name);
    tempimage = imresize(imread(imagename), [M, N]);
    subplot(5, 5, i); imshow(tempimage);
    tempimage  = double(tempimage); %change the data type to double
    X(:,i) = tempimage(:).';
    
end
% disp(size(X));
% PCA
mu = mean(X,2); %compute the mean of images as vector
% disp(length(mu));

meanNorm = X-mu;
cov =meanNorm*(meanNorm.')/(M*N); % ; cov(meanNorm.')
[EvecX, EvalX] = eig(cov); % get eigenvalues and eigenvectors from covariance matrix
[EvalSorted, index] = sort(diag(EvalX), 'descend'); %Sort eigenvalues
SortedEval = EvecX(:, index);

pca = SortedEval(:,1:K).'; %Keep 'k' number of eigenvalues for further calculation


% disp(['pca: ', num2str(size(pca))]);
% disp(['mean normalized: ', num2str(size(meanNorm))]);
reduced = (pca)*(meanNorm);
% disp(['adjust: ', num2str(size(reduced))]);
adjust = pca.'*reduced;
original = adjust + mu;

% for  i=1:1:n
%     subplot(5, 5, i); imshow(uint8(reshape(original(:, i), [M N])));
% end

error = sum(sum(original - X))/(M*N*n);

disp(['error: ', num2str(error)])