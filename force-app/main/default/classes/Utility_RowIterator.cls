/**
 * @description       : Custom iterator for CSV data
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 03-12-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class Utility_RowIterator implements Iterator<String>, Iterable<String> {
    private String data;
    private Integer index = 0;
    private String rowDelimiter = '\n';

    public Utility_RowIterator(String fileData) {
        data = fileData;
    }

    public Utility_RowIterator(String fileData, String rowDelimiter) {
        data = fileData;
        rowDelimiter = rowDelimiter;
    }

    public Boolean hasNext() {
        return index < data.length() ? true : false;
    }

    public String next() {
        Integer key = data.indexOf(rowDelimiter, index);
        if (key == -1) {
            key = data.length();
        }
        String row = data.subString(index, key);
        index = key + 1;
        return row;
    }

    public Iterator<String> iterator() {
        return this;
    }
}
