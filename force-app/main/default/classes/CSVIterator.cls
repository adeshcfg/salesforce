global with sharing class CSVIterator implements Iterator<String>, Iterable<String>
{
   private String m_CSVData;
   private String m_introValue;
   public CSVIterator(String fileData, String introValue)
   {
      m_CSVData = fileData;
      m_introValue = introValue; 
   }
   global Boolean hasNext()
   {
      return m_CSVData.length() > 1 ? true : false;
   }
   global String next()
   {
       Integer position = m_CSVData.indexOf(m_introValue);
       String row;
       if(position >= 0){
           row = m_CSVData.subString(0, position);
           m_CSVData = m_CSVData.subString(position + m_introValue.length(),m_CSVData.length());
       }else{
           row = m_CSVData.subString(0);
           m_CSVData = '';
       }
      	
      return row;
   }
   global Iterator<String> Iterator()
   {
      return this;   
   }
}