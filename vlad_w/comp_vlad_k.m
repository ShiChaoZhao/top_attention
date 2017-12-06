function enc  = comp_vlad_k(Feats, weight,centers, kdtree, pca_eigvalue, pca_eigvector, numClusters)
%	 Parameters
%    Feats             d*n dimension data with d features and n samples
%    NumFeats          number of features, here is n
%    centers           d*c dimension with d features and c centers
%    kdtree            kdtree structure of the centers
%                      kdtree = vl_kdtreebuild(centers); centers:d*c
%    pca_eigvalue      pca eigenvalue    d*reduce
%    pca_eigvector     pca_engivector    reduce*1
%    numClusters       cluster numbers   
   % disp('Quantization');
    numFeats     = size(Feats, 2);
    
    %%%%  L2 normalization
    Feats_L2     = feature_norm(Feats, 2);
%     Feats_L2     = Feats;
    %%%%  PCA and Whiten 
    Feats_PCA    = pca_eigvector' * Feats_L2;	%PCA
%     disp(['Dimension after pca:', size(Feats_PCA,1), size(Feats_PCA,2)]);
    Feats_W      = repmat( 1./sqrt(pca_eigvalue), 1, numFeats ) .* Feats_PCA;	% whitening
%     disp(['Dimension after whiten:', size(Feats_W,1), size(Feats_W,2)]);
    
%     Feats_repeat=Feats_W();
    knear        = 5; 
%   nn           = vl_kdtreequery(kdtree, centers, Feats_W) ;        %KD-tree search, d*n dimension
    [index, distance] = vl_kdtreequery(kdtree, single(centers), Feats_W, 'NumNeighbors', knear) ;% ����kdtree������  index��feats_w�������ĵ����knear���ڵ�����

%     assignments  = zeros(numClusters, numFeats);  %����Ϊ���ĵ���   ��Ϊ�����ĸ���
    assignments  = single(zeros(numClusters, numFeats));
    for kk=1:knear
        nn           = double(index(kk, :)); %ȡ��KK�У���kk=1ʱȡ����ÿ��������������ĵ��index��
        assignments(sub2ind(size(assignments), nn, 1:length(nn))) = 1; %assignment ��ÿ����������ڵĵ�KK�����ĵ�index��ֵΪ1 
    end
    
    assignments=assignments.*repmat(weight, numClusters, 1);
%     assignments = assignments/knear;%assignment��ʾÿ����������ڵ�ǰknear����ֵΪ1��ע������==�����ĸ��� ��ÿһ�б�ʾһ��������ÿһ����knear��1����Ϊ0��valdҪ��ÿһ�е�sum=1 ��ע��Ҳ���Բ�ƽ�� ÿ��k���ڿ���Ȩֵ��ͬ ����sum==1��
    
    enc      = vl_vlad(Feats_W, single(centers), assignments, 'NormalizeComponents');%vald ����
%     enc      = vl_vlad(Feats_W, centers, assignments);

%   enc = sign(enc) .* sqrt(abs(enc));	% power normalization
%   enc = enc/norm(enc);	% L2 normalization
end