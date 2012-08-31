/**********************************
 ReadData class
 
 Reads timestamped data from a file to use in Lilypad
 
 ----example code:
 reader = new ReadData("FileToRead.txt");
 float dat = reader.interpolate(t, column);
 
 ----the file should look like this, with Tabs between the data:
 #rows #cols dt
 data00 data01 data02....
 data10 data11 data12....
 ...
 
 each row is the data at a timestep - 0zth row is t=0, 1st is t=dt, etc
 
 ----you can create this file type in matlab with these commands (if 'arr' is the array of data, 'dt' is your timestep, and 'filepath' is a string that points to a text file)
header = [size(arr,1) size(arr,2) dt];
save(filepath,'header','-ascii', '-tabs');
save(filepath,'arr','-append','-ascii', '-tabs');
 ***********************************/

class ReadData {
  float[][] data;
  BufferedReader reader;
  String line;
  float dat=0, dt=1;
  int rows, cols;
  boolean verbose = true;
  char delim = TAB;

  ReadData(String filepath) {
    reader = createReader(filepath);
    readAll();
  }

  void readAll() {
    try {
      line = reader.readLine();
      String[] pieces = split(line, delim);
      rows = int(float(pieces[0]));
      cols = int(float(pieces[1]));
      dt =  float(pieces[2]);
      data = new float[rows][cols];
    }
    catch (Exception e) {
      println("Error - Bad Header");
      println(rows);
      e.printStackTrace();
    }
    if (verbose) {
      println("#Rows: " + rows + "  #Cols: " + cols + "  dt: " + dt);
    }
    for (int i=0; i<rows; i++) {
      try {
        line = reader.readLine();
      } 
      catch (Exception e) {
        println("Error - Ran out of Data");
        e.printStackTrace();
      }
      String[] pieces = split(line, delim);
      for (int j=0; j<cols; j++) {
        dat = float(pieces[j]);
        if (verbose) {
          println("Row: " + i + "  Col: " + j + "  t: " + i*dt + "  Data: " + dat);
        }
        data[i][j] = dat;
      }
    }
  }

  float interpolate(float t, int column) {
    int index = floor(t/dt);
    int next = ceil(t/dt);
    if (verbose) {
      println("Index: " + index + "  Next: " + next + "  t: " + t + "  Column: " + column);
    }
    if (next>=rows) {
      println("Requested time not within data timeseries - wrapping instead");
      next = next-rows;
    }
    if (index>=rows) {
      println("Requested time not within data timeseries - wrapping instead");
      index = index-rows;
    }
    if (column>=cols || column<0) {
      throw new Error("Requested data column not within data");
    }

    if (index==next) {
      return data[index][column];
    }

    float slope = (data[next][column]-data[index][column])/dt;
    return data[index][column]+(t-index*dt)*slope;
  }
} 

