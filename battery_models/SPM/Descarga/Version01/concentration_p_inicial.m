function [c_sp_prom] = concentration_p_inicial(r,t)
global c_smaxp beta_p100 beta_p0 

m = 2;
x = r; % Copy the input radius 

sol = pdepe(m,@pdefun,@icfun,@bcfun,x,t);
u = sol(:,:,1); % Extract the first solution component as u

% Calculation of c_s average
for i = 1:1:length(t)
    Int = 0;
    for j = 1:1:(length(r)-1)
        Int = Int + (1/2)*(r(j)^2*u(i,j) + r(j+1)^2*u(i,j+1))*(r(j+1)-r(j));
    end
    c_sp_prom(i) = Int.*(3/r(end)^3);
    if (c_sp_prom(i) < c_smaxp*beta_p100) || (c_sp_prom(i) > c_smaxp*beta_p0) || (u(i,end)/c_smaxp > 1) || (u(i,end)/c_smaxp < 0) || (u(i,1)/c_smaxp > 1) || (u(i,1)/c_smaxp < 0)
        c_sp_prom(i) = 0;
    end
end

figure(1)
surf(x,t,u)

figure(4)
subplot(2,1,1);
plot(t,c_sp_prom)
hold on
plot (t,c_smaxp*beta_p100*ones(1,length(t)),'r')
plot(t,c_smaxp*beta_p0*ones(1,length(t)),'r')
plot(t,u(:,end),'g')
plot(t,u(:,1),'k')
title('Average concentration electrode^{+}')
xlabel('Time, t [s]')
ylabel('c_{sp,prom} [mol*s^{-1}]')

end
% --------------------------------------------------------------
function [c,f,s] = pdefun(x,t,u,DuDx)
D_s = 3.7e-12;

c = 1/D_s;
f = DuDx;
s = 0;
end
% --------------------------------------------------------------
function u0 = icfun(x)
global beta_p100 c_smaxp

u0 = beta_p100*c_smaxp; % Initial concentration (t=0)
end
% --------------------------------------------------------------
function [pl,ql,pr,qr] = bcfun(xl,ul,xr,ur,t)
global I
F = 96478;
a = 3*0.5/1e-4;
L = 36.4e-4;
D_s = 3.7e-12;

if  (ur < 0) || (ur > 1) 
    I = 0;
end

pl = 0;
ql = 1;
pr = (I)./(F*a*L);
qr = D_s;
end