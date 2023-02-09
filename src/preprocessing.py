import mne
import numpy as np

def read_data(eeg_path, elec_location_path, event_markers_path):
    data = mne.io.read_raw_brainvision(eeg_path)
    elec_location = mne.channels.read_dig_captrak(elec_location_path)
    event_markers = mne.read_annotations(event_markers_path)
    return data, elec_location, event_markers

def get_marker_idx(event_markers, markers):
    idx = np.where(event_markers.description==markers)
    return idx


