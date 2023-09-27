import os

directory = "/Users/mathieubourgeois/Desktop/Analyse/C3D_to_trc"
output_directory = "/Users/mathieubourgeois/Desktop/Analyse/Traitement"

if not os.path.exists(output_directory):
    os.mkdir(output_directory)

for participant_dir in os.listdir(directory):
    participant_path = os.path.join(directory, participant_dir)
    if not os.path.isdir(participant_path):
        continue

    output_participant_dir = os.path.join(output_directory, participant_dir)
    if not os.path.exists(output_participant_dir):
        os.mkdir(output_participant_dir)

    data_dir = os.path.join(output_participant_dir, "Data")
    if not os.path.exists(data_dir):
        os.mkdir(data_dir)

    for filename in os.listdir(participant_path):
        if not filename.endswith(".trc"):
            continue

        input_path = os.path.join(participant_path, filename)
        output_path = os.path.join(data_dir, "transformed_" + filename)

        with open(input_path, "r") as f1:
            with open(output_path, "w") as f2:
                for i in range(6):
                    line = f1.readline()
                    f2.write(line)
                for line in f1:
                    values = line.split()
                    if len(values) >= 3:
                        inverted_values = []
                        for idx, val in enumerate(values):
                            if idx == 0:
                                inverted_values.append(val)
                            elif idx == 1:
                                inverted_values.append(val)
                            else:
                                if "." in val:
                                    val_float = float(val)
                                    if val_float > 0 and (idx-2) % 3 == 0:
                                        inverted_values.append("{:.6f}".format(-val_float))
                                    elif val_float < 0 and (idx-2) % 3 == 0:
                                        inverted_values.append("{:.6f}".format(abs(val_float)))
                                    elif (idx-2) % 3 == 1:
                                        inverted_values.append(values[idx+1])
                                    elif (idx-2) % 3 == 2:
                                        inverted_values.append(values[idx-1])
                                    else:
                                        inverted_values.append("{:.6f}".format(val_float))
                                else:
                                    val_int = int(val)
                                    if val_int > 0 and (idx-2) % 3 == 0:
                                        inverted_values.append(str(-val_int))
                                    elif val_int < 0 and (idx-2) % 3 == 0:
                                        inverted_values.append(str(abs(val_int)))
                                    elif (idx-2) % 3 == 1:
                                        inverted_values.append(values[idx+1])
                                    elif (idx-2) % 3 == 2:
                                        inverted_values.append(values[idx-1])
                                    else:
                                        inverted_values.append(str(val_int))

                        f2.write('\t'.join(inverted_values) + "\n")
                    else:
                        f2.write(line)
