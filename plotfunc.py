import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import geopandas as gpd
import descartes
import imageio
import pathlib


def renderPlot(df, variable, title):
    vmin, vmax = 0, df[variable].max()

    fig, ax = plt.subplots(1, figsize=(10, 6))

    # create map
    df.plot(column=variable, cmap='Blues',
            linewidth=0.8, ax=ax, edgecolor='0.8')

    # Now we can customise and add annotations

    # remove the axis
    ax.axis('off')

    # add a title
    ax.set_title(title,
                 fontdict={'fontsize': '25',
                           'fontweight': '3'})

    # create an annotation for the  data source
    ax.annotate('Source: Multi-National Forces Iraq (MNF-I) SIGACT III database',
                xy=(0.1, .08), xycoords='figure fraction',
                horizontalalignment='left', verticalalignment='top',
                fontsize=10, color='#555555')

    # Create colorbar as a legend
    sm = plt.cm.ScalarMappable(
        cmap='Blues', norm=plt.Normalize(vmin=vmin, vmax=vmax))
    sm._A = []
    cbar = fig.colorbar(sm)

    # this will save the figure as a high-res png. you can also save as svg
    fig.savefig('civiliancasualties/render/01_'+variable+'.png', dpi=300)


def renderAnimatedPlot(df, variable, iterator, title):
    output_path = 'civiliancasualties/render/animate'

    i = 0
    list_of_years = sorted(df[iterator].unique())

    # set the min and max range for the choropleth map
    vmin, vmax = df[variable].min(), df[variable].max()

    kargs = {'duration': 1}
    images = []

    # start the for loop to create one map per year
    for year in list_of_years:
        # create map
        fig = df[df.year == year].plot(column=variable, cmap='Purples', figsize=(
            10, 10), linewidth=0.8, edgecolor='0.8', vmin=vmin, vmax=vmax, legend=True, norm=plt.Normalize(vmin=vmin, vmax=vmax))

        # remove axis of chart
        fig.axis('off')

        # add a title
        fig.set_title(title,
                      fontdict={'fontsize': '25',
                                'fontweight': '3'})

        # create an annotation for the year
        only_year = year

        # position the annotation to the bottom left
        fig.annotate(only_year,
                     xy=(0.1, .225), xycoords='figure fraction',
                     horizontalalignment='left', verticalalignment='top',
                     fontsize=35)

        # this will save the figure as a high-res png in the output path. you can also save as svg if you prefer.
        filepath = os.path.join(
            output_path,
            '01_'+str(only_year)+'_'+variable+'.png')
        chart = fig.get_figure()
        chart.savefig(filepath, dpi=300)
        images.append(imageio.imread(filepath))
        os.remove(
            os.path.join(
                output_path, filename))
    imageio.mimsave('civiliancasualties/render/01_' +
                    variable+'_animated.gif', images, **kargs)
