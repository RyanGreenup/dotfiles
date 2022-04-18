local wk = require('which-key')

wk.register({
  o = {
    name = "Org", -- optional group name
    a = {"Agenda"},
    A = {"Archive"},
    c = {"Capture"},
    t = {"Set Tag"},
    r = {"Refile"},
    o = {"Open at Point"},
    k = {"Cancel Edit Source"},
    w = {"Save Edit Source"},
    K = {"Move Subtree Up"},
    J = {"Move Subtree Down"},
    e = {"Export"},
    i = {
      name = "Insert",
      d = {"Deadline"},
      h = {"Heading"},
      T = {"Mark TODO"},
      t = {"Toggle Below"},
      s = {"Schedule"}
    },
    x = {
      name = "Clock",
      o = {"Clock Out"},
      i = {"Clock In"},
      q = {"Cancel Clock"},
      j = {"Jump to Clock"},
      e = {"Set Effort"},
    }
  },
}, { prefix = "<leader>" })
