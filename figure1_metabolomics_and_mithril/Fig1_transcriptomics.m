% analyze RNA expression data 231 cells
% see Read Me for data file download

%% read files
chipfile=readtable('HG-U133A.na36annot.txt');
annotation=chipfile(26:end,1:19);

%annotate lung IDs to gene IDs
lunggsea=readtable('lunggsea.csv');
getIDslung=intersect(lunggsea{:, 1},annotation.x__ForInformationAboutTheAnnotationFileContent);
rowsl=ismember(annotation.x__ForInformationAboutTheAnnotationFileContent,getIDslung);
geneIDlung=annotation.Var15(rowsl);

braingsea=readtable('braingsea.csv');
getIDsbrain=intersect(braingsea{:, 1},annotation.x__ForInformationAboutTheAnnotationFileContent);
rowsb=ismember(annotation.x__ForInformationAboutTheAnnotationFileContent,getIDsbrain);
geneIDbrain=annotation.Var15(rowsb);

%% heatmaps
%get hallmark glycolysis genes
glyclist=readcell('hallmarkgeneset.csv');
glycbrain=[];
glyclung=[];
for i=1:length(glyclist)
    indb=find(strcmp(geneIDbrain,glyclist(i)));
    indl=find(strcmp(geneIDlung,glyclist(i)));
    if isempty(indb)
    elseif length(indb)>1
        glycbrain=[glycbrain;indb(2)];
    else
        glycbrain=[glycbrain;indb];
    end
    if isempty(indl)
    elseif length(indl)>1
        glyclung=[glyclung;indl(2)];
    else
        glyclung=[glyclung;indl];
    end
end

glycbrain=glycbrain+2; %align properly
glyclung=glyclung+2;

glycbraindata=table2array(braingsea(glycbrain,4:end));
if ~isnumeric(glycbraindata)
    glycbraindata=cellfun(@str2num,glycbraindata);
end

glyclungdata=table2array(lunggsea(glyclung,4:end));
if ~isnumeric(glyclungdata)
    glyclungdata=cellfun(@str2num,glyclungdata);
end

%FC and normalize
brainfc=mean(glycbraindata(:,4:5),2)./mean(glycbraindata(:,1:3),2);
lungfc=mean(glyclungdata(:,3:6),2)./mean(glyclungdata(:,1:2),2);
datafc=[log2(brainfc),log2(lungfc)];
clustergram(datafc,'Symmetric','false','Colormap','redbluecmap');

