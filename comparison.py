import sys
import pandas as pd
import numpy as np

control = pd.read_table(sys.args[1], index_col="tracking_id")
control = control.sort_index()
test = pd.read_table(sys.args[2], index_col="tracking_id")
test = test.sort_index()

fpkms = pd.DataFrame()
fpkms["control"] = control["FPKM"]
fpkms["test"] = test["FPKM"]
fpkms["gene_id"] = test["gene_id"]
fpkms["log_fold_change"] = np.log2(fpkms["test"]/fpkms["control"])
fpkms.to_csv(sys.args[3])
