# Ontologies & Taxonomies

This folder contains the project's semantic models, i.e., ontologies and taxonomies.


## List of Resources

- [Core taxonomy](atu-taxonomy-core.ttl) contains only the schema.
- [Full taxonomy](atu-taxonomy-full.ttl) contains the SKOS-compliant taxonomy of ATU concepts. 


## Visualizing the Taxonomies

In order to visualize the taxonomies, you can use [SKOS Play!](https://skos-play.sparna.fr/play/), a free online application to render and visualise SKOS-compliant vocabularies. Please follow the steps below:

1. Visit the [SKOS Play!](https://skos-play.sparna.fr/play/) homepage.
2. Press the "Play!" button on the top, which will take you to [this](https://skos-play.sparna.fr/play/upload) page.
3. Under section "Where is the SKOS data you want to process ?", select the [atu-taxonomy-full](atu-taxonomy-full.ttl) file and then press the "Next" button in the bottom of the screen (do not modify any of the advanced options).
4. In the next screen that appears, go to the "Visualize" section in the bottom and select the type of visualization. Tree visualization is the default, so you can leave it checked.
5. Press the "Visualize!" button and the visualization will appear.


## Roadmap

Currently, the taxonomy includes only the hierarchical information and no more information about each concept's metadata. The imminent next step is to add this information (e.g., tale ID, provenance, remarks), in order to eventually have a full-fledged taxonomy containing all the relevant information.