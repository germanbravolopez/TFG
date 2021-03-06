function TensionSalida(X1, Y1)
%CREATEFIGURE(X1, Y1)
%  X1:  vector of x data
%  Y1:  vector of y data

%  Auto-generated by MATLAB on 07-Jun-2018 05:10:51

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create plot
plot(X1,Y1);

% Create xlabel
xlabel('Tiempo, t [s]','FontName','Times New Roman');

% Create title
title('Tensi�n de salida de la bater�a');

% Create ylabel
ylabel('Tensi�n, V [V]','FontName','Times New Roman');

box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontName','Times New Roman','FontSize',11);
% Create legend
legend(axes1,'show');

