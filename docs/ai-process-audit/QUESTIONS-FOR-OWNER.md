# Questions for the owner

Everything the audit could not see. Each answer changes a finding or a recommendation.

1. **Do you read the diff before merging, or merge on green CI?** Changes R1's urgency. If you merge on green, the independent review pass on this repo is the only review there is, and R1 goes from "this week" to "today".
2. **Is the "Verify payload" check a required status on `main`?** If not, CI is optional and Lens D scores one point lower. Branch protection is a two-minute fix.
3. **Which model runs your sessions, and does it change?** The eval log in R4 needs the model column filled to be comparable across time.
4. **How many downstream repos have the payload installed today, and which ones?** Decides whether R3's version stamp is a nice-to-have or overdue, and gives R4 a population to measure.
5. **Has anything the SQL guard blocked ever been something you actually wanted to run?** A "yes" is a false-positive report and goes into the guard's tests. A "no" after a month is evidence the guard is calibrated.
6. **Licence: MIT, another open licence, or all rights reserved?** Absent today. Anyone copying the repo is doing so without terms.
7. **Do you want this audit output to stay in the repo as the worked example, or be regenerated on each re-audit?** Affects whether `audit-scorecard.yaml` is committed (it needs to be, for re-audit to diff against it).
