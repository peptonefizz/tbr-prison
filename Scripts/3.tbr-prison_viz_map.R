if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  rio, dplyr, ggplot2,
  sf, rnaturalearth, rnaturalearthdata, countrycode,
  ggrepel,here
)

project_df <- import(here("Data","tbr_project_details.csv"))

# Summarize number of projects per country
country_region <- project_df %>%
  count(country, who_region, name = "projects_count") %>%
  mutate(iso_a3 = countrycode(country, "country.name", "iso3c"))

#  world map
world <- ne_countries(returnclass = "sf")

map_data <- world %>%
  left_join(country_region, by = "iso_a3") %>%
  mutate(
    region_fill = if_else(is.na(who_region), "No projects", who_region)
  )

# Palette for WHO regions
region_colors <- c(
  "African Region"              = "#BFB0D0",
  "Eastern Mediterranean Region" = "#D0C0B0",
  "European Region"             = "#A1C181",
  "Region of the Americas"      = "#F2D388",
  "South-East Asia Region"      = "#F197CD",
  "Western Pacific Region"      = "#C0C0C0"
)

# map with Robinson projection, graticule
set.seed(42)
project_map <- ggplot(map_data) +
  geom_sf(
    aes(fill = region_fill),
    color = "#FFFFFF", size = 0.2
  ) +
  geom_text_repel(
    data = filter(map_data, projects_count > 0),
    aes(geometry = geometry, label = paste0(name, " (", projects_count, ")")),
    stat = "sf_coordinates",
    size = 2.5,
    fontface = "bold",
    min.segment.length = 0,
    segment.size = 0.3,
    segment.color = "#888888",
    segment.alpha = 0.5,
    seed = 42
  ) +
  scale_fill_manual(
    values = c(region_colors, "No projects" = "#EEEEEE"),
    breaks = names(region_colors),
    guide = guide_legend(
      title = NULL,
      ncol = 6,
      byrow = TRUE,
      label.position = "bottom",
      keywidth = unit(0.6, "cm"),
      keyheight = unit(0.3, "cm"),
      legend.margin = margin(t = 0, r = 0, b = 0, l = 0)
    )
  ) +
  coord_sf(crs = "+proj=robin", expand = FALSE) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title       = element_text(hjust = 0.5, face = "bold"),
    legend.position  = "bottom",
    legend.text      = element_text(size = 10),
    panel.grid.major = element_line(color = "#dddddd", linetype = "dotted"),
    panel.grid.minor = element_blank(),
    axis.ticks       = element_blank(),
    axis.text        = element_blank(),
    axis.title       = element_blank(),
    panel.background = element_rect(fill = "#ffffff", color = NA),
    plot.background  = element_rect(fill = "#ffffff", color = NA)
  )

print(project_map)

ggsave(here("Output","viz_map.png"),project_map, width = 10, height = 6, dpi = 300)

