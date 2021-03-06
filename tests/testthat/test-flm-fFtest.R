context("flm and fFtest")

y <- mtcars$mpg
x <- qM(mtcars[c("cyl","vs","am","carb","hp")])
w <- mtcars$wt

lmr <- lm(mpg ~ cyl + vs + am + carb + hp, mtcars)
lmw <- lm(mpg ~ cyl + vs + am + carb + hp, weights = wt, mtcars)

test_that("flm works as intended", {

  for(i in 1:6) expect_equal(drop(flm(y, x, add.icpt = TRUE, method = i)), coef(lmr))
  for(i in 1:6) expect_equal(drop(flm(y, x, w, add.icpt = TRUE, method = i)), coef(lmw))
  expect_equal(flm(y, x, method = 1L, return.raw = TRUE), .lm.fit(x, y))
  expect_equal(flm(y, x, method = 2L, return.raw = TRUE), solve(crossprod(x), crossprod(x, y)))
  expect_equal(flm(y, x, method = 3L, return.raw = TRUE), qr.coef(qr(x, LAPACK = TRUE), y))
  expect_equal(flm(y, x, method = 4L, return.raw = TRUE), RcppArmadillo::fastLmPure(x, y))
  expect_equal(flm(y, x, method = 5L, return.raw = TRUE), cinv(crossprod(x)) %*% crossprod(x, y))
  expect_equal(flm(y, x, method = 6L, return.raw = TRUE), RcppEigen::fastLmPure(x, y, 3L))
  for(i in 1:6) expect_visible(flm(y, x, w, method = i, return.raw = TRUE))
  ym <- cbind(y, y)
  for(i in c(1:3, 5L)) expect_visible(flm(ym, x, w, method = i))

  expect_error(flm(y[-1L], x, w))
  expect_error(flm(y, x, w[-1L]))
  expect_error(flm(y, x[-1L, ], w))

})


test_that("fFtest works as intended", {

  r <- fFtest(iris$Sepal.Length, gv(iris, -1L))
  rlm <- summary(lm(Sepal.Length ~., iris))
  expect_equal(unattrib(r)[1:4], unattrib(c(rlm$r.squared, rlm$fstatistic[c(2:3, 1L)])))

  r <- fFtest(wlddev$PCGDP, qF(wlddev$year), wlddev[c("iso3c","LIFEEX")])
  # Same test done using lm:
  data <- na_omit(get_vars(wlddev, c("iso3c","year","PCGDP","LIFEEX")))
  full <- lm(PCGDP ~ LIFEEX + iso3c + qF(year), data)
  rest <- lm(PCGDP ~ LIFEEX + iso3c, data)
  ranv <- anova(rest, full)

  expect_equal(rev(unattrib(r[1:2, 3L])), ranv$Res.Df)
  expect_equal(r[3L, 4L], na_rm(ranv$F))
  expect_equal(r[3L, 5L], na_rm(ranv$`Pr(>F)`))

})
