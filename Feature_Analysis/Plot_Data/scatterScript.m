st = plot_feature_vals(19, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1); ax = gca; ax.YTick = ax.YTick(1:2:end); ax.XTick = ax.XTick(1:2:end);
st.String = '';%['a) ', st.String];
pdfprint('standard_deviation_Scatter.pdf', '-dpdf')

st = plot_feature_vals(93, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1); ax = gca; ax.YTick = ax.YTick(1:2:end); ax.XTick = ax.XTick(1:2:end);
st.String = '';%['b) ', st.String];
pdfprint('AC_Scatter.pdf', '-dpdf')

st = plot_feature_vals(1763, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1); ax = gca; ax.YTick = ax.YTick(1:2:end); ax.XTick = ax.XTick(1:2:end);
st.String = '';%['c) ', st.String];
pdfprint('DN_RemovePoints_Scatter.pdf', '-dpdf')

st = plot_feature_vals(3535, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1); ax = gca; ax.YTick = ax.YTick(1:2:end); ax.XTick = ax.XTick(1:2:end);
st.String = '';%['d) ', st.String];
pdfprint('SB_MotifTwo_Scatter.pdf', '-dpdf')

st = plot_feature_vals(6275, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1); ax = gca; ax.XTick = ax.XTick(1:2:end);
st.String = '';%['e) ', st.String];
pdfprint('PP_Compare_Scatter.pdf', '-dpdf')

st = plot_feature_vals(3332, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1); ax = gca; ax.YTick = ax.YTick(1:2:end); ax.XTick = ax.XTick(1:2:end);
st.String = '';%['f) ', st.String];
pdfprint('ST_LocalExtrema_Scatter.pdf', '-dpdf')

st = plot_feature_vals(7882, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1); ax = gca; ax.XTick = ax.XTick(1:2:end);
st.String = '';%['g) ', st.String];
pdfprint('NewFeature_Scatter.pdf', '-dpdf')
