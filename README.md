# CLog4D

  This file is part of CLog4D Demo.

  CLog4D is a library file for super fast log writing for Delphi and lazarus.

  CLog4D Information - https://github.com/gaowm001/CLog4D

  This demo file uses multi-threading to write logs, which takes less than a minute to write 10,000 logs

  This program can classify and process different types of logs in one program, and write the logs to different log files.

  author:
  - GaoMing(QQ:17300620)

  *** BEGIN LICENSE BLOCK *****
  MIT License
  Copyright (c) 2019 GAOMING

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
  ***** END LICENSE BLOCK *****

  Version 0.2

  Add property:defaultdatetime, default property is 'yyyymmdd', that means the log files generated  are named by date .
  Then you can set this property to 'yyyymm' or 'yyyymmddhh', that means generate a separate log monthly or hourly .

  Version 0.1

  Example:

  First,

  uses Clog4D;

  second,

  gLogger.Writelog('Hello!');

  then,

  You will find 'LOG' directory, and log file in this dirctory.
