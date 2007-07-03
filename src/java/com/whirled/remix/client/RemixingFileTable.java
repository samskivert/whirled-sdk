//
// $Id$

package com.whirled.remix.client;

import java.awt.Component;

import java.io.File;

import java.util.EventObject;

import javax.swing.AbstractCellEditor;
import javax.swing.JFileChooser;
import javax.swing.JTable;

import javax.swing.filechooser.FileFilter;

import javax.swing.table.TableCellEditor;
import javax.swing.table.TableModel;

import com.samskivert.swing.JInternalDialog;

import com.whirled.remix.data.EditableDataPack;

public class RemixingFileTable extends AbstractTable
{
    public RemixingFileTable (EditableDataPack pack)
    {
        super(pack);
    }

    @Override
    public TableCellEditor getCellEditor (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return super.getCellEditor(row, column);

        case RemixingDataModel.VALUE_COL:
            return _fileEditor;
        }
    }

    // from AbstractTable
    protected AbstractModel createModel (EditableDataPack pack)
    {
        return new RemixingFileModel(pack, this);
    }

    /**
     * Opens a dialog for selecting a new file to be placed in the datapack.
     */
    protected void openFileDialog (int row)
    {
        RemixingFileModel model = (RemixingFileModel) getModel();
        EditableDataPack.FileEntry entry = (EditableDataPack.FileEntry) model.getEntry(row);

        JFileChooser chooser = new JFileChooser();
        chooser.setAcceptAllFileFilterUsed(false);
        chooser.setFileFilter(createFilter(entry.type));
        int result = chooser.showOpenDialog(this);
        if (result == JFileChooser.APPROVE_OPTION) {
            model.setValueAt(chooser.getSelectedFile(), row, AbstractModel.VALUE_COL);
        }
    }

    /**
     * Called to view the specified file.
     */
    protected void viewFile (int row, int column)
    {
        EditableDataPack.FileEntry entry = (EditableDataPack.FileEntry)
            ((AbstractModel) getModel()).getEntry(row);

        // TODO
        System.err.println("== file viewing is TODO [filename=" + entry.value + "].");
    }

    protected FileFilter createFilter (final EditableDataPack.FileType type)
    {
        // the following class could be replaced by 1.6's FileNameExtensionFilter
        return new FileFilter() {
            public boolean accept (File f)
            {
                String[] exts = type.getExtensions();
                if (exts == null) {
                    return true;
                }

                String endPath = f.getName();
                String extension = endPath.substring(endPath.lastIndexOf('.') + 1).toLowerCase();

                for (String ext : exts) {
                    if (ext.equals(extension)) {
                        return true;
                    }
                }
                return false;
            }

            public String getDescription ()
            {
                return type.getDescription();
            }
        };
    }

    protected class FileFakeEditor extends AbstractCellEditor
        implements TableCellEditor
    {
        // from TableCellEditor
        public Component getTableCellEditorComponent (
            JTable table, Object value, boolean isSelected, int row, int col)
        {
            openFileDialog(row);
            cancelCellEditing();
            return null;
        }

        // from CellEditor
        public Object getCellEditorValue ()
        {
            return null;
        }
    }

    protected FileFakeEditor _fileEditor = new FileFakeEditor();
}
