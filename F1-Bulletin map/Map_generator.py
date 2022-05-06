from qgis.PyQt import *
from qgis.core import *
from qgis.PyQt.QtGui import *
from PyQt5 import Qt
import datetime

QgsProject.instance().clear()

#Create project
project = QgsProject.instance()
crs = project.crs()
crs.createFromId(4326)
project.setCrs(crs)

#Import layers
#Set path to layers
basemap_path = r"C:\Users\stoop_go\OneDrive - Stichting Deltares\Documents\QGIS projects\F1-Bulletin map\Skobbler_basemap.xml"
HSI_fishing_path = r"C:\Users\stoop_go\OneDrive - Stichting Deltares\Documents\QGIS projects\F1-Bulletin map\20220414T000000000Z.tif"
boundaries_path = r"C:\Users\stoop_go\OneDrive - Stichting Deltares\Documents\QGIS projects\F1-Bulletin map\RO_BG_EEZ_Boundaries_polygon.shp"

#Define path and name
basemap_layer = QgsRasterLayer(basemap_path, "Basemap")
HSI_fishing_layer = QgsRasterLayer(HSI_fishing_path, "Fishing index")
boundaries_layer = QgsVectorLayer(boundaries_path, "Boundaries")

#Import layers to project
project.addMapLayer(basemap_layer)
project.addMapLayer(HSI_fishing_layer)
project.addMapLayer(boundaries_layer)

################################################################
#Editing the indiviual layers
################################################################

###Editing HSI_fishing_layer###

#Set color ramp
ColorRamp = QgsColorRampShader(0.8,1)
ColorRamp.setColorRampType(QgsColorRampShader.Interpolated)
ColorRampRange = [QgsColorRampShader.ColorRampItem(0.8, QColor(255,0,0)), QgsColorRampShader.ColorRampItem(0.9, QColor(255,255,0)), QgsColorRampShader.ColorRampItem(1, QColor(0,255,0))]
ColorRamp.setColorRampItemList(ColorRampRange)
ApplyRamp = QgsRasterShader()
ApplyRamp.setRasterShaderFunction(ColorRamp)
renderer = QgsSingleBandPseudoColorRenderer(HSI_fishing_layer.dataProvider(), 1, ApplyRamp)
HSI_fishing_layer.setRenderer(renderer)

####Editing Boudaries layer###

#Make layer transparent and dashed
boundaries_layer.renderer().symbol().setColor(QColor("transparent"))
boundaries_layer.renderer().symbol().symbolLayer(0).setStrokeStyle(Qt.Qt.PenStyle(Qt.Qt.DashDotDotLine))

#Add labels to boundaries
boundaries_settings = QgsPalLayerSettings()
boundaries_settings.fieldName = "country"
boundaries_settings.enabled = True

#Add label to "country" field
boundaries_text_settings = QgsTextFormat()
boundaries_text_settings.setFont(QFont("Arial",12))
boundaries_text_settings.setColor(QColor(23,111,176))
boundaries_text_settings.setSize(16)
boundaries_settings.setFormat(boundaries_text_settings)
boundaries_settings.placement = 0

label = QgsVectorLayerSimpleLabeling(boundaries_settings)
boundaries_layer.setLabelsEnabled(True)
boundaries_layer.setLabeling(label)


#Set some default extentsChange
Romania_Bulgaria = QgsRectangle(QgsPointXY(27.4279,41.9930), QgsPointXY(31.3539,45.2156))
Romania = QgsRectangle(QgsPointXY(28.5068,43.6589), QgsPointXY(31.2541,45.1989))
Bulgaria = QgsRectangle(QgsPointXY(30.0658,43.6589), QgsPointXY(27.4326,41.9573))


################################################################
#Creation of the mapframe
################################################################

###Create layout with settings###

#Give a name to layout
layoutName = 'F1 layout'

#Assign variable with layout manager class
layout_manager = project.layoutManager()

#If layout exists, delete it
layouts_list = layout_manager.printLayouts()
for items in layouts_list:
    if items.name() == layoutName:
        manager.removeLayout(items)

#Add the project including the list of layers to the layout
layout = QgsPrintLayout(project)
#Initialize default settings
layout.initializeDefaults()
#Give the layout a name
layout.setName(layoutName)

#set layout size
layout_size = layout.pageCollection()
layout_size.pages()[0].setPageSize('A4', QgsLayoutItemPage.Orientation.Portrait)
#add current layout to the manager of layouts
layout_manager.addLayout(layout)

###Map-item###

#add the layout as a map item in the print manager
map = QgsLayoutItemMap(layout)
map.setRect(30, 30, 30, 30)

#set the map extent
map_settings = QgsMapSettings()
#Choose which layer the extent will be set to
map_settings.setLayers([HSI_fishing_layer])
#Display the full extent of the layer otherwise custom x and y can be set
rect = Bulgaria
rect.scale(1.0)
#set the map extent to the defined rectangle
map_settings.setExtent(rect)
#set mapframe to the same extent
map.setExtent(rect)

###Grid###

grid = QgsLayoutItemMapGrid("Grid", map)
grid.Cross
grid.setIntervalX(0.5)
grid.setIntervalY(0.5)
grid.setAnnotationEnabled(True)
grid.setAnnotationPosition(QgsLayoutItemMapGrid.InsideMapFrame,QgsLayoutItemMapGrid.Bottom)
grid.setAnnotationPosition(QgsLayoutItemMapGrid.InsideMapFrame, QgsLayoutItemMapGrid.Left)
grid.setAnnotationPosition(QgsLayoutItemMapGrid.InsideMapFrame, QgsLayoutItemMapGrid.Right)
grid.setAnnotationPosition(QgsLayoutItemMapGrid.InsideMapFrame, QgsLayoutItemMapGrid.Top)
grid_line = QgsSimpleLineSymbolLayer()
grid_line.setPenStyle(Qt.Qt.PenStyle(Qt.Qt.DotLine))
grid_line.setColor(QColor(23,111,176))
grid_line_symbol = QgsLineSymbol()
grid_line_symbol.changeSymbolLayer(0, grid_line)
grid.setLineSymbol(grid_line_symbol)

map.grids().addGrid(grid)

#add map item to layout
layout.addLayoutItem(map)


#sent upper left corner of the map item
map.attemptMove(QgsLayoutPoint(0, 30, QgsUnitTypes.LayoutMillimeters))
#set size of the map item
map.attemptResize(QgsLayoutSize(210, 260, QgsUnitTypes.LayoutMillimeters))

###Legend###

#Create a legend item in the map layout
legend = QgsLayoutItemLegend(layout)
legend.setTitle("Legend")
legend.setSymbolHeight(50)
legend.setAutoUpdateModel(False)
legend.setFontColor(QColor(23,111,176))

#Build layer tree layer 0 = boundaries, layer 1 = hsi whiting, layer 3 = basemap
layerTree = QgsLayerTree()
layerTree.addLayer(HSI_fishing_layer)
layerTree.addLayer(boundaries_layer)
layerTree.addLayer(basemap_layer)
layerTreeModel = QgsLayerTreeModel(layerTree)
#Remove layers from legend
legend.model().rootGroup().removeLayer(boundaries_layer)
legend.model().rootGroup().removeLayer(basemap_layer)
#Remove "band 1 - (grey)" node from legend
HSI_LayerTreeLayer = legend.model().rootGroup().findLayer(HSI_fishing_layer)
QgsMapLayerLegendUtils.setLegendNodeOrder(HSI_LayerTreeLayer,[1])
legend.model().refreshLayerLegend(HSI_LayerTreeLayer)
#add to layout
layout.addLayoutItem(legend)
legend.attemptMove(QgsLayoutPoint(180.5, 218, QgsUnitTypes.LayoutMillimeters))

###Title###
title = QgsLayoutItemLabel(layout)
title.setText("HSI-whiting fishing index")
title.setFont(QFont('Arial', 30))
title.setFontColor(QColor(23,111,176))
title.adjustSizeToText()
title.setHAlign(Qt.Qt.AlignCenter)
layout.addLayoutItem(title)
title.attemptResize(QgsLayoutSize(235,15, QgsUnitTypes.LayoutMillimeters))
title.attemptMove(QgsLayoutPoint(10,2.5, QgsUnitTypes.LayoutMillimeters))

###Sub-title###
subtitle = QgsLayoutItemLabel(layout)
Date = datetime.datetime.now()
print(Date)
subtitle.setText("{}".format(Date.strftime("%A %d-%m-%Y")))
subtitle.setFont(QFont('Arial', 16))
subtitle.setFontColor(QColor(23,111,176))
subtitle.adjustSizeToText()
subtitle.setHAlign(Qt.Qt.AlignLeft)
layout.addLayoutItem(subtitle)
subtitle.attemptResize(QgsLayoutSize(125,9,QgsUnitTypes.LayoutMillimeters))
subtitle.attemptMove(QgsLayoutPoint(70,15,QgsUnitTypes.LayoutMillimeters))

###Scale-bar###
scalebar = QgsLayoutItemScaleBar(layout)
scalebar.applyDefaultSettings()
scalebar.setUnits(QgsUnitTypes.DistanceKilometers)
scalebar.setSegmentSizeMode(1)
scalebar.setLinkedMap(map)
scalebar.setUnitLabel("km")
layout.addLayoutItem(scalebar)
scalebar.attemptResize(QgsLayoutSize(75,13, QgsUnitTypes.LayoutMillimeters))
scalebar.attemptMove(QgsLayoutPoint(15,268, QgsUnitTypes.LayoutMillimeters))

###Logo###
logo = QgsLayoutItemPicture(layout)
logo.setPicturePath(r"C:\Users\stoop_go\OneDrive - Stichting Deltares\Documents\QGIS projects\F1-Bulletin map\FORCOAST_Logo_WhiteBack.png")
layout.addLayoutItem(logo)
logo.attemptResize(QgsLayoutSize(50,50,QgsUnitTypes.LayoutMillimeters))
logo.attemptMove(QgsLayoutPoint(5,0,QgsUnitTypes.LayoutMillimeters))

###Footer###
footer = QgsLayoutItemPicture(layout)
footer.setPicturePath(r"C:\Users\stoop_go\OneDrive - Stichting Deltares\Documents\QGIS projects\F1-Bulletin map\FORCOAST_Footer_Blue.png")
layout.addLayoutItem(footer)
footer.attemptResize(QgsLayoutSize(210,6.65, QgsUnitTypes.LayoutMillimeters))
footer.attemptMove(QgsLayoutPoint(0,290,QgsUnitTypes.LayoutMillimeters))

#############################################################
#Print layout to image or pdf
#############################################################
exporter = QgsLayoutExporter(layout)

#export_path_pdf = r"C:\Users\stoop_go\OneDrive - Stichting Deltares\Documents\QGIS projects\F1-Bulletin map\F1-Bulletin-map.pdf"
export_path_png = r"C:\Users\stoop_go\OneDrive - Stichting Deltares\Documents\QGIS projects\F1-Bulletin map\F1-Bulletin-map.png"
#exporter.exportToPdf(export_path_pdf, QgsLayoutExporter.PdfExportSettings())
exporter.exportToImage(export_path_png, QgsLayoutExporter.ImageExportSettings())

