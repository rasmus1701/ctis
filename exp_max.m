function [f_out] = exp_max(H,g,iter,d,lambda)

f_iter = (H')*g;   #Initial guess
h_sum = sum(H,1);  #precompute fixed sums

for m=1:iter
    g_iter = H*f_iter;
    g_div = g./g_iter;
    g_div(isnan(g_div) | isinf(g_div)) = 0;

    for n=1:length(f_iter)
        f_next(n) = (f_iter(n)'./h_sum(n))'.*sum(H(:,n).*g_div);
    end
    f_iter = f_next';
end
f_out=f_iter;

#Egne tilf�jelser herunder, da f_out er en vektor og ikke en cube og �nskes konverteret til kube form

#d = sqrt(size(g,1)/25);	     	#Finder st�rrelsen af kuben indirekte via st�rrelsen af g
f_out = reshape(f_out,lambda,d,d);	#Laver f-beregnet om til en kube, desv�rre vender kuben forkert ift. oprindelig f
f_temp = zeros(d,d,lambda);		# s� en l�kken herunder "vender" den 90 grader, s� den er sammenlignelig

for ii=1:lambda
    for jj=1:d
        f_temp(jj,:,ii)=f_out(ii,:,jj);
    end
end

f_out=f_temp;

endfunction
