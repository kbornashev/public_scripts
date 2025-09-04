import numpy as np
import matplotlib.pyplot as plt
from ipywidgets import interact, IntSlider
def plot_weeding(weeding_hours, weeding_days, weeding_weeks, weeding_months,
                 offset_hours, offset_days, offset_weeks, offset_months):
    backup_times = np.arange(0, 1000, 24)  # Пример временных точек бекапов каждые 24 часа на протяжении 1000 часов
    time_points = np.array(backup_times)
    fig, ax = plt.subplots(figsize=(10, 6))

    if weeding_hours != -1:
        hours_weeding_start = max(time_points[-1] - weeding_hours / 3600, 0)
        hours_to_keep = time_points[time_points >= hours_weeding_start][::1]
        ax.barh('Hourly', weeding_hours / 3600, left=hours_weeding_start, color='red', alpha=0.5)
        ax.scatter(hours_to_keep, ['Hourly']*len(hours_to_keep), color='green', s=100, label='Keep')

    if weeding_days != -1:
        days_weeding_start = max(time_points[-1] - weeding_days / 86400, 0)
        days_to_keep = time_points[time_points >= days_weeding_start][::24]
        ax.barh('Daily', weeding_days / 86400, left=days_weeding_start, color='red', alpha=0.5)
        ax.scatter(days_to_keep, ['Daily']*len(days_to_keep), color='green', s=100, label='Keep')

    if weeding_weeks != -1:
        weeks_weeding_start = max(time_points[-1] - weeding_weeks / 604800, 0)
        weeks_to_keep = time_points[time_points >= weeks_weeding_start][::168]
        ax.barh('Weekly', weeding_weeks / 604800, left=weeks_weeding_start, color='red', alpha=0.5)
        ax.scatter(weeks_to_keep, ['Weekly']*len(weeks_to_keep), color='green', s=100, label='Keep')

    if weeding_months != -1:
        months_weeding_start = max(time_points[-1] - weeding_months / (30*86400), 0)
        months_to_keep = time_points[time_points >= months_weeding_start][::720]
        ax.barh('Monthly', weeding_months / (30*86400), left=months_weeding_start, color='red', alpha=0.5)
        ax.scatter(months_to_keep, ['Monthly']*len(months_to_keep), color='green', s=100, label='Keep')
    ax.set_xlabel('Time (hours)')
    ax.set_ylabel('Weeding Interval')
    ax.set_title('Backup Weeding Visualization')
    ax.legend(loc='upper right')
    ax.grid(True)
    plt.show()
interact(plot_weeding,
         weeding_hours=IntSlider(min=-1, max=86400*2, step=3600, value=86400, description='Weeding Hours'),
         weeding_days=IntSlider(min=-1, max=86400*14, step=86400, value=604800, description='Weeding Days'),
         weeding_weeks=IntSlider(min=-1, max=86400*56, step=604800, value=-1, description='Weeding Weeks'),
         weeding_months=IntSlider(min=-1, max=86400*365, step=86400*30, value=-1, description='Weeding Months'),
         offset_hours=IntSlider(min=0, max=20, step=1, value=10, description='Offset Hours'),
         offset_days=IntSlider(min=0, max=20, step=1, value=10, description='Offset Days'),
         offset_weeks=IntSlider(min=0, max=10, step=1, value=1, description='Offset Weeks'),
         offset_months=IntSlider(min=0, max=10, step=1, value=1, description='Offset Months'))
