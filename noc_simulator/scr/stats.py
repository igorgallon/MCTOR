import json
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import constants

REGRESSION_LINE_DEGREE = 3

###################################################
# Statistics Calculation Functions
###################################################

def get_throughput(df):
    '''
    Calculate throughput as the number of arrived flits divided by the total cycles taken for each execution_id.
    '''
    cycles = df[df['type'] == 'packet_arrived'].groupby('execution_id').max()['cycles'].reset_index(name='cycles')
    arrived_flit = df[df['type'] == 'packet_arrived'].groupby('execution_id').count()['packet_id'].reset_index(name='arrived_flits')
    stats = pd.merge(cycles, arrived_flit, on='execution_id')
    stats['throughput'] = stats['arrived_flits'] / stats['cycles']
    return stats[['execution_id', 'throughput']]


def get_average_latency(df):
    '''
    Calculate the average latency for each execution_id.
    '''
    df_injected = df[df['type'] == 'packet_sent'].copy()
    # Get the latency mean
    df_arrived = df[df['type'] == 'packet_arrived'].copy()

    df_diff_cycles = pd.merge(
        df_arrived[['packet_id', 'cycles', 'execution_id']],
        df_injected[['packet_id', 'cycles', 'execution_id']],
        on=['packet_id', 'execution_id'],
        suffixes=('_arrived', '_injected')
    )
    df_diff_cycles['cycles'] = df_diff_cycles['cycles_arrived'] - df_diff_cycles['cycles_injected']
    # Get the latency mean
    return df_diff_cycles.groupby(['execution_id']).agg({'cycles': 'mean'}).reset_index().rename(columns={'cycles': 'latency_mean'})


def get_mean_extra_delay(df):
    '''
    Calculate the mean extra delay for each execution_id.
    Extra delay is defined as the difference between the mean latency and the minimum latency for packets of
    the same execution_id.
    '''
    df_injected = df[df['type'] == 'packet_sent'].copy()
    df_arrived = df[df['type'] == 'packet_arrived'].copy()
    
    df_diff_cycles = pd.merge(
        df_arrived[['packet_id', 'cycles', 'execution_id']],
        df_injected[['packet_id', 'cycles', 'execution_id']],
        on=['packet_id', 'execution_id'],
        suffixes=('_arrived', '_injected')
    )
    # Get the latency for each packet
    df_diff_cycles['cycles'] = df_diff_cycles['cycles_arrived'] - df_diff_cycles['cycles_injected']
    # Get min and mean latency per execution_id
    latency_stats = df_diff_cycles.groupby('execution_id')['cycles'].agg(['min', 'mean']).reset_index()
    latency_stats['extra_delay'] = latency_stats['mean'] - latency_stats['min']
    return latency_stats[['execution_id', 'extra_delay']]


def get_packet_loss(df):
    '''
    Calculate packet loss for each execution_id.
    '''
    df_injected = df[df['type'] == 'packet_sent'].copy()
    df_arrived = df[df['type'] == 'packet_arrived'].copy()
    
    df_total_injected = df_injected.groupby('execution_id').size().reset_index(name='total_injected')
    df_total_arrived = df_arrived.groupby('execution_id').size().reset_index(name='total_arrived')

    df_packet_loss = pd.merge(
        df_total_arrived[['execution_id', 'total_arrived']],
        df_total_injected[['execution_id', 'total_injected']],
        on='execution_id'
    )
    df_packet_loss['packet_loss'] = df_packet_loss['total_injected'] - df_packet_loss['total_arrived']
    return df_packet_loss[['execution_id', 'packet_loss']]


###################################################
# Statistics Plotting Functions
###################################################

def _plot_throughput_comparison(ax, all_stats, colors, title_fontsize=12, is_individual=False):
    """Helper function to plot throughput comparison"""
    for algo, stats in all_stats.items():
        ax.plot(range(len(stats)), stats['throughput'], marker='o', linestyle='-', 
               linewidth=2, label=algo, color=colors.get(algo))
    ax.set_title('Throughput Comparison', fontsize=title_fontsize, fontweight='bold')
    ax.set_xlabel('Traffic Rate Index')
    ax.set_ylabel('Throughput (flits/cycle)')
    ax.legend()
    ax.grid(True, alpha=0.3)


def _plot_latency_comparison(ax, all_stats, colors, title_fontsize=12, is_individual=False):
    """Helper function to plot latency comparison"""
    for algo, stats in all_stats.items():
        ax.plot(range(len(stats)), stats['latency_mean'], marker='s', linestyle='-', 
               linewidth=2, label=algo, color=colors.get(algo))
    ax.set_title('Average Latency Comparison', fontsize=title_fontsize, fontweight='bold')
    ax.set_xlabel('Traffic Rate Index')
    ax.set_ylabel('Latency (cycles)')
    ax.legend()
    ax.grid(True, alpha=0.3)


def _plot_extra_delay_comparison(ax, all_stats, colors, title_fontsize=12, is_individual=False):
    """Helper function to plot extra delay comparison"""
    for algo, stats in all_stats.items():
        ax.plot(range(len(stats)), stats['extra_delay'], marker='^', linestyle='-', 
               linewidth=2, label=algo, color=colors.get(algo))
    ax.set_title('Extra Delay Comparison', fontsize=title_fontsize, fontweight='bold')
    ax.set_xlabel('Traffic Rate Index')
    ax.set_ylabel('Extra Delay (cycles)')
    ax.legend()
    ax.grid(True, alpha=0.3)


def _plot_packet_loss_comparison(ax, all_stats, colors, title_fontsize=12, is_individual=False):
    """Helper function to plot packet loss comparison"""
    for algo, stats in all_stats.items():
        # ax.plot(range(len(stats)), stats['packet_loss'], marker='^', linestyle='-', 
        #        linewidth=2, label=algo, color=colors.get(algo))
        z = np.polyfit(range(len(stats)), stats['packet_loss'], 2)
        p = np.poly1d(z)
        ax.plot(range(len(stats)), p(range(len(stats))), linestyle='-', linewidth=2, 
               label=algo, color=colors.get(algo))
    ax.set_title('Packet Loss Comparison', fontsize=title_fontsize, fontweight='bold')
    ax.set_xlabel('Traffic Rate Index')
    ax.set_ylabel('Lost Packets')
    ax.legend()
    ax.grid(True, alpha=0.3)


###################################################
# Utility Functions
###################################################

def save_execution_parameters(context, metrics_folder):
    """
    Save the execution parameters from the context dictionary to a CSV file.
    """
    import os
    p = dict(context)

    os.makedirs(metrics_folder, exist_ok=True)
    params_file = f"{metrics_folder}/execution_parameters.json"
    p["MAX_BUFFER_SIZE"] = constants.MAX_BUFFER_SIZE
    p["INJECTION_PATTERN"] = constants.INJECTION_PATTERN
    p["ARBITER_ALGORITHM"] = constants.ARBITER_ALGORITHM
    p["SELECTION_STRATEGY"] = constants.SELECTION_STRATEGY
    p["RETRY_MECHANISM"] = constants.ENABLE_RETRY_MECHANISM
    p["RETRY_LIMIT"] = constants.RETRY_LIMIT

    json.dump(p, open(params_file, "w"), indent=2)
    
    return params_file


def plot_all_algorithms_comparison(all_stats, metrics_folder, context=None):
    """
    Create comparison plots for all routing algorithms.
    all_stats: dict with routing algorithm names as keys and stats dataframes as values
    context: simulation configuration dictionary
    """
    colors = {'XY': '#1f77b4', 'NEGATIVE_FIRST': '#ff7f0e', 'WEST_FIRST': '#2ca02c', 'NORTH_LEAST': '#d62728'}
    
    # Create combined 2x2 comparison plot
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle('Simulation Statistics - All Routing Algorithms Comparison', fontsize=16, fontweight='bold')
    
    # Add configuration text box
    if context:
        save_execution_parameters(context, metrics_folder)
        config_text = "Configuration:\n"
        config_text += f"  Mesh Size: {context.get('mesh_size', 'N/A')}\n"
        config_text += f"  Simulation Steps: {context.get('simulation_steps', 'N/A')}\n"
        config_text += f"  Max Flits/Node: {context.get('max_flits_per_node', 'N/A')}\n"
        config_text += f"  Traffic Range: {context.get('input_traffic_rate', ['N/A'])[0]:.2%} - {context.get('input_traffic_rate', ['N/A'])[-1]:.2%}"
        
        fig.text(0.99, 0.01, config_text, fontsize=9, ha='right', va='bottom',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.3),
                family='monospace')
    
    # Plot to combined figure
    _plot_throughput_comparison(axes[0, 0], all_stats, colors, title_fontsize=12)
    _plot_latency_comparison(axes[0, 1], all_stats, colors, title_fontsize=12)
    _plot_extra_delay_comparison(axes[1, 0], all_stats, colors, title_fontsize=12)
    _plot_packet_loss_comparison(axes[1, 1], all_stats, colors, title_fontsize=12)
    
    plt.tight_layout()
    
    # Save combined comparison plot
    comparison_file = f"{metrics_folder}/comparison_all_algorithms.png"
    fig.savefig(comparison_file, dpi=200, bbox_inches='tight')
    plt.close(fig)
    
    # Save individual plots
    fig_throughput, ax_throughput = plt.subplots(figsize=(12, 7))
    _plot_throughput_comparison(ax_throughput, all_stats, colors, title_fontsize=14, is_individual=True)
    fig_throughput.tight_layout()
    fig_throughput.savefig(f"{metrics_folder}/throughput_comparison.png", dpi=200, bbox_inches='tight')
    plt.close(fig_throughput)
    
    fig_latency, ax_latency = plt.subplots(figsize=(12, 7))
    _plot_latency_comparison(ax_latency, all_stats, colors, title_fontsize=14, is_individual=True)
    fig_latency.tight_layout()
    fig_latency.savefig(f"{metrics_folder}/latency_comparison.png", dpi=200, bbox_inches='tight')
    plt.close(fig_latency)
    
    fig_extra_delay, ax_extra_delay = plt.subplots(figsize=(12, 7))
    _plot_extra_delay_comparison(ax_extra_delay, all_stats, colors, title_fontsize=14, is_individual=True)
    fig_extra_delay.tight_layout()
    fig_extra_delay.savefig(f"{metrics_folder}/extra_delay_comparison.png", dpi=200, bbox_inches='tight')
    plt.close(fig_extra_delay)
    
    fig_packet_loss, ax_packet_loss = plt.subplots(figsize=(12, 7))
    _plot_packet_loss_comparison(ax_packet_loss, all_stats, colors, title_fontsize=14, is_individual=True)
    fig_packet_loss.tight_layout()
    fig_packet_loss.savefig(f"{metrics_folder}/packet_loss_comparison.png", dpi=200, bbox_inches='tight')
    plt.close(fig_packet_loss)
    
    return comparison_file


def calculate_metrics(metrics_file):
    """
    Load metrics from CSV, calculate statistics, and returns merged statistics dataframe.
    """
    df = pd.read_csv(metrics_file)
    
    # Calculate all statistics
    throughput = get_throughput(df)
    latency = get_average_latency(df)
    extra_delay = get_mean_extra_delay(df)
    packet_loss = get_packet_loss(df)
    
    # Merge all statistics
    stats = pd.merge(throughput, latency, on='execution_id')
    stats = pd.merge(stats, extra_delay, on='execution_id')
    stats = pd.merge(stats, packet_loss, on='execution_id')

    return stats
