function ModelModels3D(varnum)
if(nargin<1)
    varnum=9; %Default to B_z
end

%Define what run you want to use
runname='Victoir_Veibell_041316_1';
%Default headers for model data
dataheaders={'x','y','z','x','y','z','B_x','B_y','B_z','jx','jy','jz','ux','uy','uz','p','rho'};


%Filename to save data to for easier/quicker future reading
filename=sprintf('data/%s/DifferencesData_%s_3D.mat',runname,runname);

%Commented out until I decide the best way to read in all the data
%{
if(exist(filename,'file'))
    load(filename)
else

    
    [status,ncuts]=system(sprintf('ls -1 data/%s/data/cuts/ | wc -l',runname));
    ncuts=str2double(ncuts);
    for i=1:ncuts
        data(i,:,:)=dlmread(sprintf('data/%s/data/cuts/Step_%02d_Y_eq_0.txt',runname,i-1)); 
    end

    inputvars={'Year','Month','Day','Hour','Min','Sec','Msec','Bx[nT]','By[nT]','Bz[nT]','Vx[km/s]','Vy[km/s]','Vz[km/s]','N[cm^(-3)]','T[Kelvin]'};

    inputs=dlmread(sprintf('data/%s/%s_IMF.txt',runname,runname));
    
    for i=1:(ncuts-1)
        bininputs(i,:)=median(inputs((i-1)*30+1:i*30,:));
    end
    bininputs(ncuts,:)=median(inputs((ncuts-1)*30+1:end,:));
    
    save(filename,'data','inputs','bininputs','inputvars');
    
end
%}

%Read in CDF and convert to workable matrix. Note, not all variables have
%the same amount of rows, but since we're selecting  ones that do we can
%convert straight to a matrix, and then to a double() for the sake of the
%following functions that require doubles.
test=cdfread('/home/victoir/Work/Differences/data/Victoir_Veibell_041316_1/GM_CDF/3d__var_1_e20100101-000000-000.out.cdf','Variables',{'x','y','z','bx','by','bz','rho'});
testmat=double(cell2mat(test));

%Interpolate onto a mesh grid.
F=scatteredInterpolant(double(testmat(:,1)),double(testmat(:,2)),double(testmat(:,3)),double(testmat(:,7)));
[X,Y,Z]=meshgrid(linspace(min(testmat(:,1)),max(testmat(:,1)),100),linspace(min(testmat(:,2)),max(testmat(:,2)),100),linspace(min(testmat(:,3)),max(testmat(:,3)),100));
V=F(double(X),double(Y),double(Z));
X=X(:);
Y=Y(:);
Z=Z(:);
V=V(:);
%Can attempt to plot all data, but plotting 1M points is a bit much
%scatter3(X(:),Y(:),Z(:),[],V(:))

%Only plotting points of interest at a certain contour. Un-hard-code this
%as threshold+-epsilon
POI=((V(:)<1.9)+(V(:)>1.8))>1;
scatter3(X(POI),Y(POI),Z(POI),[],V(POI),'.','LineWidth',0.1)
print('-depsc2','-r200', 'NoteFigures/InterpScatter3.eps')

%Testing non-interpolated grid
POI2=((testmat(:,7)<1.9)+(testmat(:,7)>1.8))>1;
scatter3(testmat(POI2,1),testmat(POI2,2),testmat(POI2,3),[],testmat(POI2,7),'.','LineWidth',0.1)
print('-depsc2','-r200', 'NoteFigures/OriginalScatter3.eps')


%Interpolated isosurface selects specific value and makes solid surface for
%it.
isosurface(X,Y,Z,V,2)

%First workings of an animation
for i=[100 10 5 2 1.8 1.5 1.3 1 0.5 0.1]
    close all; 
    isosurface(X,Y,Z,V,i); 
    pause(2);
end





