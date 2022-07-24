package atu;

import com.opencsv.CSVReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.FileReader;
import java.util.HashSet;

public class AtuTaxonomyGenerator {
    private static Logger logger = LoggerFactory.getLogger(AtuTaxonomyGenerator.class); // Logging facility

    public AtuTaxonomyGenerator(String filePath) {
        HashSet<AtuObj> atuObjects = parseHierarchy(filePath);
        /*for(AtuObj atuObject : atuObjects) {
            System.out.println(atuObject);
        }*/
    }

    private HashSet<AtuObj> parseHierarchy(String filePath) {
        logger.info("Parsing hierarchy...");
        HashSet<AtuObj> atuObjects = new HashSet<>();
        try {
            CSVReader reader = new CSVReader(new FileReader(filePath));
            reader.readNext(); // Ignore first line that has the headers
            String [] line;
            while ((line = reader.readNext()) != null) {
                String chapter = line[0], division = line[1], sub_division = line[2], atu_id = line[3], tale_name = line[4], litvar = line[5], provenance = line[6], tale_type = line[7], remarks = line[8], combos = line[9];

                String immediateParent = chapter;
                if(!exists(atuObjects, chapter)) {
                    atuObjects.add(new AtuObj(chapter));
                }
                if(!division.equals("NA")) {
                    immediateParent = division;
                    if(!exists(atuObjects, division)) {
                        atuObjects.add(new AtuObj(division));
                    }
                    getAtuObjByName(atuObjects, division).setParent(chapter);
                }
                if(!sub_division.equals("NA")) {
                    immediateParent = sub_division;
                    if(!exists(atuObjects, sub_division)) {
                        atuObjects.add(new AtuObj(sub_division));
                    }
                    getAtuObjByName(atuObjects, sub_division).setParent(division);
                }
                if(!exists(atuObjects, tale_name)) {
                    atuObjects.add(new AtuObj(tale_name));
                }
                getAtuObjByName(atuObjects, tale_name).setParent(immediateParent);
            }
            logger.info("Hierarchy parsing complete - No. of instances created: " + atuObjects.size());
        } catch(Exception ex) {
            logger.error(ex.getMessage());
            ex.printStackTrace();
        } finally {
            return atuObjects;
        }
    }

    // Retrieves a specific ATU from the set of ATUs
    private AtuObj getAtuObjByName(HashSet<AtuObj> atuObjects, String atuName) {
        for(AtuObj atuObject : atuObjects) {
            if(atuObject.getName().equals(atuName)) return atuObject;
        }
        return null;
    }

    // Checks if a specific ATU exists in the set of ATUs
    private boolean exists(HashSet<AtuObj> atuObjects, String atuName) {
        for(AtuObj atuObject : atuObjects) {
            if(atuObject.getName().equals(atuName)) {
                return true;
            }
        }
        return false;
    }
}