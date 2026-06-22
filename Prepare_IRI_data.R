# Prepare IRI Data
# Network Analysis of Empathy (IRI) — data preparation
# Project : reproducibility case study (Briganti et al., 2018 replication + gender comparison)
# Source  : Han (2023), "Examining the network structure among moral functioning components with network analysis",
#           The IRI (empathy) is one of five questionnaires in this dataset; we extract ONLY the 28 IRI items here.
# Output  : a clean, analysis-ready data frame of the 28 IRI items
#           (raw items, readable node labels) + gender.

# 1. Configuration
# data_dir <- "Data_Han" ## Put your own path here 
files <- c(
  "HAN_DISC_SONA.csv",
  "HAN_ESPRMC_2020Spring.csv",
  "HAN_ESPRMC_2020Fall.csv",
  "HAN_ESPRMC_2021Spring.csv",
  "HAN_ESPRMC_2021Fall.csv",
  "HAN_ESPRMC_2022Spring.csv",
  "HAN_ESPRMC_2022Fall.csv",
  "HAN_ESPRMC_2023Spring.csv"
)

# 2. IRI structure (Davis, 1980/1983)
# In this dataset the 28 IRI items are the Qualtrics variables Q164_1 ... Q164_28,
# and Q164_<n> corresponds exactly to Davis IRI item <n> 
iri_items <- paste0("Q164_", 1:28)

# Subscale membership, indexed by item number 1..28:
#   FS = Fantasy, PT = Perspective Taking, EC = Empathic Concern, PD = Personal Distress
subscale <- c("FS","EC","PT","EC","FS","PD","FS","PT","EC","PD",
              "PT","FS","PD","EC","PT","FS","PD","EC","PD","EC",
              "PT","EC","FS","PD","PT","FS","PD","PT")
stopifnot(length(subscale) == 28)

# (Normally) reverse-scored items (Davis): 3, 4, 7, 12, 13, 14, 15, 18, 19. But since Briganti does not do that, we keep the same logic.
reverse_items <- c(3, 4, 7, 12, 13, 14, 15, 18, 19)

# Readable node labels: subscale + Davis item number (e.g. "PT3", "EC4").
# Reverse-keyed items get an "_R" suffix (as in Briganti), for interpretation only.
node_labels <- paste0(subscale, 1:28)
node_labels[reverse_items] <- paste0(node_labels[reverse_items], "_R")

# 3. Load each file, keep only needed columns, tag with source 
keep <- c(iri_items, "Sex", "Age")

read_one <- function(f) {
  d <- read.csv(file.path(data_dir, f), header = TRUE,
                stringsAsFactors = FALSE, na.strings = c("", "NA"))
  # safety net: if a column is unexpectedly absent -> NA
  for (m in setdiff(keep, names(d))) d[[m]] <- NA
  out <- d[, keep, drop = FALSE]
  out$source <- f
  out
}

raw_list <- lapply(files, read_one)
dat <- do.call(rbind, raw_list)

# Coerce IRI items + Age to numeric (a few files store them as character).
dat[iri_items] <- lapply(dat[iri_items], function(x) as.numeric(as.character(x)))
dat$Age        <- as.numeric(as.character(dat$Age))

cat("Total stacked rows:", nrow(dat), "\n")          # expect 1612

# 4. Reverse-scoring: UIT, om Briganti te volgen (ruwe items, zoals empathy_Syntax.R).
reverse_score <- FALSE
if (reverse_score) {
  rev_cols <- paste0("Q164_", reverse_items)
  dat[rev_cols] <- lapply(dat[rev_cols], function(x) 6 - x)
}

# 5. Gender 
# Han (2023): the sample is 85.49% women
# Sex == 2 in the data. Coding therefore is: 1 = Male, 2 = Female.
dat$gender <- factor(dat$Sex, levels = c(1, 2), labels = c("Male", "Female"))

# 6. Build the analysis frame with readable node names 
iri <- dat[, iri_items]
names(iri) <- node_labels
iri$gender <- dat$gender
iri$age    <- dat$Age

# 7. Missingness + complete cases 
items_ok  <- complete.cases(iri[, node_labels])
cat("Complete on all 28 IRI items:", sum(items_ok), "\n")          # expect 1505

# Primary analysis sample: complete on items AND gender, so that H1 (overall),
# H2 and H3 (gender comparison) all use the same respondents. This reproduces
# the published N = 1468.
keep_rows  <- items_ok & !is.na(iri$gender)
iri_ready  <- iri[keep_rows, ]
cat("Analysis-ready N (items + gender):", nrow(iri_ready), "\n")   # expect 1468
cat("\nGender breakdown:\n"); print(table(iri_ready$gender))

# 8. Sanity checks 
rng <- range(as.matrix(iri_ready[, node_labels]), na.rm = TRUE)
cat("\nItem value range (should be 1-5):", rng[1], "-", rng[2], "\n")

# Subscale grouping (use for qgraph 'groups=' when you plot the network)
groups <- list(
  Fantasy           = node_labels[subscale == "FS"],
  PerspectiveTaking = node_labels[subscale == "PT"],
  EmpathicConcern   = node_labels[subscale == "EC"],
  PersonalDistress  = node_labels[subscale == "PD"]
)

# 9. Save analysis-ready objects 
saveRDS(list(data = iri_ready, groups = groups, node_labels = node_labels),
        file = "iri_analysis_ready.rds") 
write.csv(iri_ready, "iri_analysis_ready.csv", row.names = FALSE)

cat("\nSaved: iri_analysis_ready.rds  and  iri_analysis_ready.csv\n")


# NOTE for H2/H3: groups are very unequal (213 men vs 1255 women). The male
# network is estimated on a small sample, so check its stability carefully and
# interpret the NCT power accordingly.
