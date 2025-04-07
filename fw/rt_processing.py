#!/usr/bin/python

# -*- coding: utf-8 -*-
#
# Copyright (C) 2022 Dododtronix
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA  02110-1301, USA.
#
# You can dowload a copy of the GNU General Public License here:
# http://www.gnu.org/licenses/gpl.txt

import sys
import signal
import ctypes

import numpy as np
import logging as lg
import pyqtgraph as pg 

from os import sep
from time import sleep
from sys import platform, path
from PyQt6 import QtWidgets, QtGui, QtCore 

lg.basicConfig(level=lg.DEBUG) 

dwf = ctypes.cdll.LoadLibrary("libdwf.so")
constants_path = (f"{sep}usr{sep}share{sep}digilent"
                  f"{sep}waveforms{sep}samples{sep}py")


#import constants
path.append(constants_path)
import dwfconstants as constants

class ThreadSignals(QtCore.QObject):
    """ 
    Because QRunnable is not derived from 
    QObject the signals have to be added 
    from external object
    """
    finished = QtCore.pyqtSignal()
    fetched = QtCore.pyqtSignal(object)

class FetchData(QtCore.QRunnable):
    """
    This thread class takes function fetching 
    data from external module method and 
    returnig the data in dictionary format
    """

    def __init__(self, fn):
        super(FetchData, self).__init__()
        self.fn = fn
        self.signals = ThreadSignals()

    def run(self):
        c = self.fn()

        self.signals.fetched.emit(c)
        self.signals.finished.emit()

class MainWindow(QtWidgets.QMainWindow):

    def __init__(self, *args, **kwargs):
        super(MainWindow, self).__init__(*args, **kwargs)
        self.logger = lg.getLogger(__name__)
        self.threadpool = QtCore.QThreadPool()

        self.size = 8000
        self.data = np.zeros((self.size, 1))

        # Application name
        self.wname = ("REAL-TIME PROCESSING")
        self.setWindowTitle(self.wname)

        # # NOTE Main layout structure 
        self.main_layout_horizontal = QtWidgets.QHBoxLayout()
        self.tabular_chart_widgets = QtWidgets.QVBoxLayout() 
        self.complete_window_design = QtWidgets.QVBoxLayout()

        self.app_name = QtWidgets.QLabel(self.wname)
        self.app_name.setAlignment(QtCore.Qt.AlignmentFlag.AlignCenter)

        self.graph = self.get_scope_chart(self.tabular_chart_widgets, "HAPTIX")  
        
        # NOTE Assemble layouts
        self.complete_window_design.addWidget(self.app_name)
        self.main_layout_horizontal.addLayout(self.tabular_chart_widgets)
        self.complete_window_design.addLayout(self.main_layout_horizontal)

        # NOTE Show created window configuration 
        self.w = QtWidgets.QWidget()
        self.w.setLayout(self.complete_window_design)
        self.setCentralWidget(self.w)

        # Periodicaly check for interrupts 
        self.timer = QtCore.QTimer()
        # self.timer.timeout.connect(self.fetch_data)
        self.timer.start(100)

    def get_chart_canvas(self):
        lay = pg.GraphicsLayout()
        lay.layout.setContentsMargins(20, 20, 20, 20)
        gview = pg.GraphicsView()
        gview.setCentralItem(lay)
        gview.setBackground('w')
        return gview, lay

    def get_scope_chart(self, qtlayout, name):
        gv, l = self.get_chart_canvas()
        qtlayout.addWidget(gv)
        p = l.addPlot(title=name)
        p.showGrid(x=True, y=True, alpha=0.4)
        p.setLabels(bottom='Time [s]')
        chart = p.plot(pen=pg.mkPen('r', width=2))
        return chart

    def update_chart(self, data):
        self.data = np.vstack((data.reshape(-1, 1), self.data[:-len(data)]))
        self.graph.setData(self.data.flatten())

class Analyzer:

    def __init__(self):
        self.logger = lg.getLogger(__name__)
        self.threadpool = QtCore.QThreadPool()
        self.app = QtWidgets.QApplication(sys.argv)

        # self.hdwf = ctypes.c_int()
        # dwf.FDwfDeviceOpen(ctypes.c_int(-1), ctypes.byref(self.hdwf))
        # if self.hdwf.value == 0:
        #     print("Failed to open device")
        #     sys.exit()
        #
        # dwf.FDwfAnalogInFrequencySet(
        #     self.hdwf, ctypes.c_double(1e6)) # 1MHz sampling
        # dwf.FDwfAnalogInBufferSizeSet(
        #     self.hdwf, ctypes.c_double(1e6)) # buffer size
        # dwf.FDwfAnalogInChannelEnableSet(
        #     self.hdwf, ctypes.c_int(1), ctypes.c_int(2)) # Enable channel 1
        # dwf.FDwfAnalogInConfigure(
        #     self.hdwf, ctypes.c_int(1), ctypes.c_int(1)) # start acquisition

    def start(self):
        self.gui = MainWindow()
        self.gui.show() 
        self.wait_for_data()
        sys.exit(self.app.exec())

    def fetch(self):
        return np.random.randint(2**10, size=10)

    def wait_for_data(self):
        dd = FetchData(self.fetch)
        dd.signals.fetched.connect(self.gui.update_chart)
        dd.signals.finished.connect(self.wait_for_data)
        self.threadpool.start(dd)

def launch():
    # this serves to be able to close window 
    # with Ctr-C command from console
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    analyzer = Analyzer()
    analyzer.start()

if __name__ == '__main__':
    launch()

