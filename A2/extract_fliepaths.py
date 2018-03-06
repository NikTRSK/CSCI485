import os

for d in os.listdir('./data'):
	db_name = d[:-4]
	full_path = os.path.abspath(d)
	print(full_path)
	# print("COPY \"" + db_name + "\" from '" + full_path + "' WITH (FORMAT CSV);")
	# print (os.path.abspath(d))

# COPY "User" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data/User.csv' WITH (FORMAT CSV );