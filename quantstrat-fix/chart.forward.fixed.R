
chart.forward <- function (audit.filename, 
                           portfolio.name=stop("portfolio.name must be set!")) 
{
    if (is.null(.audit)) 
        stop("You need to run a walk forward test first to create the .audit environment")
    if (!is.null(audit.filename)) 
        load(audit.filename)
    else stop("You need to provide an audit.filename.")
    portfolios.st = ls(name = .audit, pattern = "portfolio.*.[0-9]+")
    n <- length(portfolios.st)
    PL.xts <- xts()
    for (portfolio.st in portfolios.st) {
        p <- getPortfolio(portfolio.st, envir = .audit)
        from <- index(p$summary[2])
        R <- cumsum(p$summary[paste(from, "/", sep = ""), "Net.Trading.PL"])
        names(R) <- portfolio.st
        PL.xts <- cbind(PL.xts, R)
    }
    
    # FIXME: remove the hardcoded part
    # portfolio.st <- "opt"
    portfolio.st <- portfolio.name
    # portfolio.st <- "portfolio.forex"
    p <- getPortfolio(portfolio.st, envir = .audit)
    from <- index(p$summary[2])
    R <- cumsum(p$summary[paste(from, "/", sep = ""), "Net.Trading.PL"])
    names(R) <- portfolio.st
    PL.xts <- na.locf(cbind(PL.xts, R))
    CumMax <- cummax(PL.xts)
    Drawdowns.xts <- -(CumMax - PL.xts)
    data.to.plot <- as.xts(cbind(PL.xts, Drawdowns.xts))
    
    p <- plot(PL.xts, col=c("blue", rep("grey", n-1)), main="Walk Forward Analysis")
    # set on=NA so it is drawn on a new panel
    p <- lines(Drawdowns.xts, col=c("blue", rep("grey", n-1)), on=NA, main="Drawdowns")
    print(p)
    
    .audit <- NULL
}

