import atu.AtuTaxonomyGenerator;

public class Main {
    public static void main(String[] args) {
        new AtuTaxonomyGenerator(
                "data/atu_df.csv", // path to CSV file
                "http://localhost:7200/repositories/atu-taxonomy" // SPARQL endpoint
        );
    }
}