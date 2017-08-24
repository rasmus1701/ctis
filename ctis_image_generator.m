
D=3;         #Data cube dimension 
Lambda=5;      #Number of spectral lines
bit=256;		#maximum value of voxel in datacube.

dist=0; #round(D/2);         #Distance between 0th and 1st order
Z=D*3+Lambda*2;    #FPA dimension
#Z=5*D; #-2
midt=floor((Z)/2);

background=zeros(Z,Z);
image=background;
m=floor(bit*rand(D,D,Lambda));      #generates random Object cube

mSum=zeros(D,D);
for i=1:Lambda
    mSum=mSum+m(:,:,i);
end

for i=1:D
    for j=1:D
        image(midt-(D-1)/2+i,midt-(D-1)/2+j)=mSum(i,j);       #0th order
    end
end

image=image*D/Lambda;

for h=1:Lambda
    for i=1:D
        for j=1:D
            image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j)=image(midt-(D-1)/2+i+D+dist+h,midt-(D-1)/2+j)+m(i,j,h);    #Bottom
            image(midt-(D-1)/2+i,midt-(D-1)/2+j+(D+dist+h))=image(midt-(D-1)/2+i,midt-(D-1)/2+j+D+dist+h)+m(i,j,h);    #Right
            image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j)=image(midt-(D-1)/2+i-D-dist-h,midt-(D-1)/2+j)+m(i,j,h);    #Top
            image(midt-(D-1)/2+i,midt-(D-1)/2+j-(D+dist+h))=image(midt-(D-1)/2+i,midt-(D-1)/2+j-D-dist-h)+m(i,j,h);    #Left
            image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j+(D+dist+h))=image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j+(D+dist+h))+m(i,j,h);  #Bottom-Right
            image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j-(D+dist+h))=image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j-(D+dist+h))+m(i,j,h);  #Bottom-Left
            image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j+(D+dist+h))=image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j+(D+dist+h))+m(i,j,h);  #Top-Right
            image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j-(D+dist+h))=image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j-(D+dist+h))+m(i,j,h);  #Top-Left
        end
    end
#    clc
    status=h*100/Lambda;
    #disp(status,"Status percent");
end

a=max(image);
#scale=256/a;

#xset("colormap",graycolormap(256))
#xname("image1 wavelength all")
#Matplot(image*scale,strf="021")

#disp("Simulation ended after")
#TimeEnd=toc()
#disp("seconds",TimeEnd)

#output = reshape(m,D,D*D);

f = m;
#g = reshape(image,9*D*D+6*Lambda*D+4*Lambda*Lambda,1);
S=size(image,1);

g = reshape(image,S*S,1);