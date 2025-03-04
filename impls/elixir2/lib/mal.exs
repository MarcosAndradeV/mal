
case System.argv() do
  ["step0_repl"] -> Mal.Step0.repl()
  ["step1_read_print"] -> Mal.Step1.repl()
  ["step2_eval"] -> Mal.Step2.repl()
  ["step3_env"] -> Mal.Step3.run()
  ["step4_if_fn_do"] -> Mal.Step4.run()
  ["step5_tco"] -> Mal.Step5.run()
  a -> raise("#{a} is not implemented")
end
