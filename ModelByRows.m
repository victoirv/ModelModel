function ModelByRows(runname,runvars,xvar,fvar)

if(nargin<1 || isempty(runname))
    runname='Victoir_Veibell_092716_1'; %Default to ux
end
if(nargin<2 || isempty(runvars))
    runvars={'x','y','z','ux','uy','uz','bx','by','bz','jx','jy','jz','rho','p'};
end
if(nargin<3 || isempty(xvar))
    xvar=9; %Default to bz
end
if(nargin<4 || isempty(fvar))
    fvar=[8:15]; %Default to everything
end


filename=sprintf('data/%s/SolarWindData.mat',runname);

if(exist(filename,'file'))
    load(filename)
else
    %Variable names for model input data (solar wind)
    inputvars={'Year','Month','Day','Hour','Min','Sec','Msec','Bx[nT]','By[nT]','Bz[nT]','Vx[km/s]','Vy[km/s]','Vz[km/s]','N[cm^(-3)]','T[Kelvin]'};
    
    %Read in solar wind data
    inputs=dlmread(sprintf('data/%s/%s_IMF.txt',runname,runname));
    
    
    %Bin the input data to be on the same grid as the model data that came
    %from brian's code
    save(filename,'inputs','inputvars');
end


basedir=sprintf('/home/victoir/Work/Differences/data/%s/GM_CDF/',runname);
files=dir(sprintf('%s/*%s.mat',basedir,strjoin(runvars,'')));
FigureBase=sprintf('%s_%s_%s',runname(end-7:end-2),runvars{xvar},num2str(fvar,'%d'));

%Because the model will output all solar wind conditions, but only the first subset of model run data once you hit a file size limit
inputs=inputs(1:length(files),:);

x=zeros(length(files),1);
corrmat=x.*-1;
chunksize=5000;

currentfile=sprintf('%s/%s',basedir,files(1).name);
matObj=matfile(currentfile);
N = max(size(matObj,'readdata'));

filenamecorr=sprintf('data/%s/%s_%s_corr.mat',runname,num2str(xvar),num2str(fvar,'%d'));
%corrObj=matfile(filenamecorr,'Writable',true);

x=double(matObj.readdata(:,1));
y=double(matObj.readdata(:,2));
z=double(matObj.readdata(:,3));

%{
corrObj.x=x;
corrObj.y=y;
corrObj.z=z;
corrObj.corrmat=zeros(length(x),1);
%}

if(~exist(filenamecorr,'file'))
    startpoint=1;
    endpoint=startpoint+chunksize-1;
    data=zeros(length(files),chunksize,length(matObj.keepvars));
else
    load(filenamecorr)
    startpoint=find(corrmat==-1,1);
    if(~isempty(startpoint))
        fprintf('File already started. Skipping to index %d\n',startpoint);
        if(startpoint+chunksize<=N)
            endpoint=startpoint+chunksize;
        else
            endpoint=N;
        end
        data=zeros(length(files),endpoint-startpoint+1,5);
        
    else
        fprintf('Correlations already complete. To regenerate, delete the file. Moving on to plotting')
        startpoint=-1;
    end
    
end

warning('off','all')
if(startpoint>0)
    while(startpoint>0)
        for i=1:length(files)
            currentfile=sprintf('%s/%s',basedir,files(i).name);
            matObj=matfile(currentfile);
            %fprintf('Reading %s\n',currentfile);
            %format is data(time,space,var)
            data(i,:,:)=matObj.readdata(startpoint:endpoint,:);
        end
        fprintf('Correlating elements %d - %d\n',startpoint,endpoint-1);
        for j=1:(endpoint-startpoint)
            [~,~,~,~,corr]=IR(data(:,j,xvar),inputs(:,fvar),0,10);
            corrmat(startpoint+j-1)=corr;
        end
        %Write results so far to file. Doesn't seem to like vector addressing
        %corrObj.corrmat(startpoint:endpoint)=corrmat(startpoint:endpoint);

        save(filenamecorr,'x','y','z','corrmat','-v7.3');
        if(startpoint+chunksize>N)
            startpoint=0;
        elseif(endpoint+chunksize>N)
            endpoint=N;
            startpoint=startpoint+chunksize-1;
            data=zeros(length(files),endpoint-startpoint+1,5);
        else
            startpoint=startpoint+chunksize-1;
            endpoint=startpoint+chunksize-1;
        end
    end
    save(filenamecorr,'x','y','z','corrmat','-v7.3');
end

figure;
POI=abs(y)<=1;
[Xg,Zg]=meshgrid(linspace(min(x(POI)),max(x(POI)),200),linspace(min(z(POI)),max(z(POI)),200));
vq=griddata(x(POI),z(POI),corrmat(POI),Xg,Zg);
surf(Xg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
ylabel('Z (R_E)') %Y-axis in plot is Z-axis in space
colorbar
title(sprintf('Correlations of %s on the Y=0 cutplane interpolated from grid points of Y<=1',runvars{xvar}))
print('-depsc2','-r200',sprintf('figures/Y0Correlations-Near_%s.eps',FigureBase))
print('-dpng','-r200',sprintf('figures/PNGs/Y0Correlations-Near_%s.png',FigureBase))
