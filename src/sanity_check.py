import mne


def run_check(data):    
    # See data info
    print("==== info ==== ")
    print(data.info)
    
    # See available channels
    print("==== Channels ====")
    print(data.info['ch_names'])
    
    # Plot psd
    figure = data.plot_psd()
    figure.savefig('output/testfig.png')



