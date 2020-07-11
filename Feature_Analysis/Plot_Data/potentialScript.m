x = 0:0.001:10;
figure
hold on
plot(x, -(-0.01).*x.^2./2 + x.^4./4, '-k', 'LineWidth', 3)
ax = gca;
ax.XAxis.Visible = 'off';
ax.YAxis.Visible = 'off';
ax.XLim = [0, 1];
ax.YLim = [0, 0.5];
xline(0, '--k', 'LineWidth', 3)
