with open("/Users/mathieubourgeois/Desktop/Dossier_biomeca_2_part2/DATA/Fichier_trc/hugo_2.trc", "r") as f1:
    with open("/Users/mathieubourgeois/Desktop/TEST/Test.trc", "w") as f2:
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
