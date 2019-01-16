class TestPipe < Through::Pipe
  pipe_with :name do |hash, name, _|
    hash.merge({ name: name })
  end

  pipe_with :email, if: -> (email, _) { email.length > 5 } do |hash, email, _|
    hash.merge({
      email: email,
    })
  end

  pipe_without :secret, if: -> (_, context) { context.has_key?(:secret) } do |hash, _, context|
    puts context.inspect
    hash.merge({ secret: context[:secret] })
  end

  pipe_without :except do |hash, _, _|
    hash.merge({ except: false })
  end

  pipe do |hash, _|
    hash.merge({ default: true })
  end

  pipe if: -> (context) { context.has_key?(:context) } do |hash, _|
    hash.merge({ context: true })
  end
end

RSpec.describe Through::Pipe do
  it "has a version number" do
    expect(Through::VERSION).not_to be nil
  end

  it "should pipe through default pipe if no paramters are provided" do
    hash = TestPipe.new({}).through()
    expect(hash).to eq({
      default: true,
      except: false
    })
  end

  it "should not pipe through without pipe if paramter is provided" do
    hash = TestPipe.new({}).through({ except: "" })
    expect(hash).to eq({
      default: true,
    })
  end

  it "should pipe through with pipe if paramter is provided" do
    name = "Foo bar"
    hash = TestPipe.new({}).through({ name: name })
    expect(hash).to eq({
      default: true,
      except: false,
      name: name
    })
  end

  it "should pipe through with pipe if paramter is provided and invalidate the if option" do
    name = "Foo bar"
    hash = TestPipe.new({}).through({
      name: name,
      email: "< 5"
    })
    expect(hash).to eq({
      default: true,
      except: false,
      name: name
    })
  end

  it "should pipe through with pipe if paramter is provided and validate the if option" do
    name = "Foo bar"
    email = "greater that five chars"
    hash = TestPipe.new({}).through({
      name: name,
      email: email
    })
    expect(hash).to eq({
      default: true,
      except: false,
      name: name,
      email: email
    })
  end

  it "should pipe through context pipe if it validates the if option" do
    hash = TestPipe.new({}, { context: true }).through()
    expect(hash).to eq({
      context: true,
      default: true,
      except: false,
    })
  end

  it "should pipe and give context has a third block parameter" do
    secret = "SECRET"
    hash = TestPipe.new({}, { secret: secret }).through()
    expect(hash).to eq({
      secret: secret,
      default: true,
      except: false,
    })
  end
end
