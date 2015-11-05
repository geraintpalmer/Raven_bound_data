import sys
from csv import reader, writer
load('MCs.sage')

def import_params(directory, sffx):
	"""
	Imports the rows of parameters
	"""
	params_list = []
	param_file = open('%sparams_%i.csv' % (directory, sffx), 'r')
	rdr = reader(param_file)
	for row in rdr:
		params_list.append(row)
	param_file.close()
	return params_list

def import_done_data(directory, sffx):
	"""
	Imports the rows of parameters
	"""
	done_list = []
	try:
		done_file = open('%sbound_data%i.csv' % (directory, sffx), 'r')
		rdr = reader(done_file)
		for row in rdr:
			prow = [str(Rational(eval(row[4]))), str(Rational(eval(row[5]))), str(Rational(eval(row[2]))), str(Rational(eval(row[3]))), str((eval(row[6]), eval(row[7]))), str((eval(row[8]), eval(row[9]))), str(Rational(eval(row[0]))), str(Rational(eval(row[1])))]
			done_list.append(prow)
		done_file.close()
	except IOError:
		pass
	return done_list

def check_whats_done(directory, params_list):
	"""
	Check which parameters have already been done
	"""
	not_done = []
	done_list = import_done_data(directory, sffx)
	for row in params_list:
		if row not in done_list:
			not_done.append(row)
	return not_done

def append_row_to_csv_file(row, directory, sffx):
	"""
	Appends row to csv file
	"""
	results_file = open('%sbound_data%i.csv' % (directory, sffx), 'a')
	csv_wrtr = writer(results_file, delimiter=',')
	csv_wrtr.writerow(row)
	results_file.close()

def calculate_row(params):
	"""
	Calculates the row to write
	"""
	n1, n2 = Rational(params[0]), Rational(params[1])
	mu1, mu2 = Rational(params[2]), Rational(params[3])
	r11, r12, r21, r22 = Rational(eval(params[4])[0]), Rational(eval(params[4])[1]), Rational(eval(params[5])[0]), Rational(eval(params[5])[1])
	L1, L2 = Rational(params[6]), Rational(params[7])
	mu1_dash = (mu2/(mu1+mu2))/((2.0/mu1)+(1.0/mu2))
	mu2_dash = (mu1/(mu2+mu1))/((1.0/mu1)+(2.0/mu2))

	Q11_s = OneNodeNetwork(n1, mu1, r11, L1)
	Q11_s.find_mean_time_to_absorbtion()
	Q11_ss = OneNodeNetwork(n1, mu1_dash, r11, L1)
	Q11_ss.find_mean_time_to_absorbtion()
	Q12_s = OneNodeNetwork(n2, mu2, r22, L2)
	Q12_s.find_mean_time_to_absorbtion()
	Q12_ss = OneNodeNetwork(n2, mu2_dash, r22, L2)
	Q12_ss.find_mean_time_to_absorbtion()
	Q2 = TwoNodeSimpleNetwork(n1, n2, mu1, mu2, r12, r21, L1, L2)
	Q2.find_mean_time_to_absorbtion()
	Q = TwoNodeFeedbackNetwork(n1, n2, mu1, mu2, r11, r12, r21, r22, L1, L2)
	Q.find_mean_time_to_absorbtion()
	bound = min(max(Q11_ss.mean_time_to_absorbtion['0'], Q11_s.mean_time_to_absorbtion['0']), max(Q12_ss.mean_time_to_absorbtion['0'], Q12_s.mean_time_to_absorbtion['0']), Q2.mean_time_to_absorbtion['(0, 0)'])
	ratio_inverse = Q.mean_time_to_absorbtion['(0, 0)'] / bound
	Q.find_absorpion_probabilities()
	pr1, pr2, pr3 = Q.absorbtion_probabilities

	return [float(L1), float(L2), float(mu1), float(mu2), int(n1), int(n2), float(r11), float(r12), float(r21), float(r22), float(pr1), float(pr2), float(pr3), float(ratio_inverse)]

@parallel
def find_bound_data(param_list, directory, sffx):
	"""
	Main function that goes through all parameter combinations and writes the row to csv file
	"""
	row = calculate_row(param_list)
	append_row_to_csv_file(row, directory, sffx)
	return None

if __name__ == '__main__':
	arguments = sys.argv
	directory = arguments[1]
	sffx = int(arguments[2])
	import_list = import_params(directory, sffx)
	param_list = check_whats_done(directory, import_list)
	parallel_data = find_bound_data([(p, directory, sffx) for p in param_list])
	for obs in parallel_data:
		dummy = obs
