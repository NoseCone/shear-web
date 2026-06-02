fun renderComp (comp : Comp.compInput) : string =
  case comp of
    Comp.CompInput c =>
      let
        val tz =
          case c.UtcOffset of
            Comp.UtcOffset u => show u.TimeZoneMinutes

        val radius =
          case c.EarthModel of
            Comp.EarthAsSphere e => e.Radius

        val giveDistance =
          case c.GiveConfig of
            Comp.GiveConfig g => g.GiveDistance

        val giveFraction =
          case c.GiveConfig of
            Comp.GiveConfig g => show g.GiveFraction

        val scoreBack =
          case c.ScoreBack of
            Comp.ScoreBackTime s => show s ^ " s"
      in
        "CivilId: " ^ c.CivilId ^ "\n"
        ^ "EarthMath: " ^ c.EarthMath ^ "\n"
        ^ "Discipline: "
        ^ (case c.Discipline of
             Comp.HangGliding => "hg"
           | Comp.Paragliding => "pg")
        ^ "\n"
        ^ "Location: " ^ c.Location ^ "\n"
        ^ "From: " ^ c.From ^ "\n"
        ^ "To: " ^ c.To ^ "\n"
        ^ "CompName: " ^ c.CompName ^ "\n"
        ^ "UtcOffset.TimeZoneMinutes: " ^ tz ^ "\n"
        ^ "Earth.sphere.radius: " ^ radius ^ "\n"
        ^ "Give.giveDistance: " ^ giveDistance ^ "\n"
        ^ "Give.giveFraction: " ^ giveFraction ^ "\n"
        ^ "ScoreBack: " ^ scoreBack
      end
