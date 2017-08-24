D=3;				#Kubens x,y dimensioner
Lambda=5;       		#antal spektrale lag
#H=zeros(D*D*25,D^3);        	#genererer en tom H kube i de rigtige dimensioner for en kubisk datakube
                                # ellers har den st�rrelsen (9DD+12DLambda+4LambdaLambda , DDLambda)
h_iter=1;                       #t�ller
H = zeros(9*D*D+12*D*Lambda+4*Lambda*Lambda, D*D*Lambda);

for x_iter=1:D                  #looper igennem alle punkter i datakuben (x,y,lambda)
    for y_iter=1:D
        for lambda_iter=1:Lambda

            dist=0;	#round(D/2);#Distance between 0th and 1st order = 0+1 pixel
            Z=D*3+Lambda*2;
            #Z=5*D;
            midt=floor((Z)/2);

            background=zeros(Z,Z);		#laver et tomt billede
            image=background;

            m=zeros(D,D,Lambda);		#laver tom data kube med nuller
            m(x_iter,y_iter,lambda_iter)=1;	#s�tter �n voxel i kuben til 1 - denne skiftes for hver iteration.

            mSum=zeros(D,D);
            for i=1:Lambda
                mSum=mSum+m(:,:,i);		#beregner 0te orden ved at summe alle spektral lag
            end

            for i=1:D
                for j=1:D
                  image(midt-(D-1)/2+i,midt-(D-1)/2+j)=mSum(i,j);       #0th order generated in the image
                end
            end

            image=image*D/Lambda;

            for h=1:Lambda	#laver de 8 diffraktionsordener
                for i=1:D
                  for j=1:D
                    image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j) = image(midt-(D-1)/2+i+D+dist+h,midt-(D-1)/2+j)+m(i,j,h);    #Bottom
                    image(midt-(D-1)/2+i,midt-(D-1)/2+j+(D+dist+h)) = image(midt-(D-1)/2+i,midt-(D-1)/2+j+D+dist+h)+m(i,j,h);    #Right
                    image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j) = image(midt-(D-1)/2+i-D-dist-h,midt-(D-1)/2+j)+m(i,j,h);    #Top
                    image(midt-(D-1)/2+i,midt-(D-1)/2+j-(D+dist+h)) = image(midt-(D-1)/2+i,midt-(D-1)/2+j-D-dist-h)+m(i,j,h);    #Left
                    image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j+(D+dist+h)) = image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j+(D+dist+h))+m(i,j,h);  #Bottom-Right
                    image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j-(D+dist+h)) = image(midt-(D-1)/2+i+(D+dist+h),midt-(D-1)/2+j-(D+dist+h))+m(i,j,h);  #Bottom-Left
                    image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j+(D+dist+h)) = image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j+(D+dist+h))+m(i,j,h);  #Top-Right
                    image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j-(D+dist+h)) = image(midt-(D-1)/2+i-(D+dist+h),midt-(D-1)/2+j-(D+dist+h))+m(i,j,h);  #Top-Left
                  end
                end
            end

            a=max(image);
            #scale=256/a;			#beregner en max v�rdi til senere plot

            #xset("colormap",graycolormap(256))
            #xname("image1 wavelength all")
            #Matplot(image*scale,strf="021")	#plotter

            f=m;				#kalder datakuben for f for at synkronisere med litteratur
            #g=reshape(image,D*D*25,1);		#laver CTIS billedete om til en g-vektor 
            S=size(image,1);

            g = reshape(image,S*S,1);

            H(:,h_iter) = g;			#smider g-vektoren ind som en s�jle i H kuben
            h_iter = h_iter+1;			#t�ller op
        end
    end
end             #slut p� x,y,lambda l�kken fra start
