import preprocessing as pre
import params as p
import numpy as np

data, elec_location, event_markers = pre.read_data(p.eeg_path, p.elec_location_path, p.event_markers_path)

markers_1 = pre.get_marker_idx(event_markers, p.markers_before_tbs[0])[0]
markers_2 = pre.get_marker_idx(event_markers, p.markers_before_tbs[1])[0][0:-300]
markers_before = np.hstack([markers_1, markers_2])

print(len(markers_before))

markers_1 = pre.get_marker_idx(event_markers, p.markers_after_tbs[0])[0]
markers_2 = pre.get_marker_idx(event_markers, p.markers_after_tbs[1])[0]
markers_after = np.hstack([markers_1, markers_2])

print(len(markers_after))

after_tbs_mi = event_markers.onset[markers_after]
print(after_tbs_mi)

print(data.info)