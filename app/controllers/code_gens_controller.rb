# -*- encoding : utf-8 -*-

class CodeGensController < ApplicationController

    helper :zip
    before_action :set_code_gen, only: [:show, :edit, :update, :destroy]

    # GET /code_gens
    # GET /code_gens.json
    def index
        @code_gens = CodeGen.all
    end

    # GET /code_gens/1
    # GET /code_gens/1.json
    def show
    end

    # GET /code_gens/new
    def new
        @code_gen = CodeGen.new
    end

    # GET /code_gens/1/edit
    def edit
    end

    # POST /code_gens
    # POST /code_gens.json
    def create
        @code_gen = CodeGen.new(code_gen_params)

        case @code_gen.project_name
            when 'haitao'
                coding = CodeGensHelper::HaitaoCodeGen.new(@code_gen.project_name)
            when 'supplier'
                coding = CodeGensHelper::SupplierCodeGen.new(@code_gen.project_name)
            else
                raise 'No Support Project!'
        end
        coding.generate_code(@code_gen.table_name,@code_gen.package_name)

        out_path = "#{Rails.root}/config/out/#{@code_gen.table_name}"

        file = Tempfile.new([@code_gen.table_name, '.zip'])
        zf = ZipHelper::ZipFileGenerator.new(out_path, file.path)
        zf.write()

        send_file(file.path)
        # respond_to do |format|
        #     format.html { redirect_to @code_gen, notice: 'Code gen was successfully created.' }
        #     format.json { render :show, status: :created, location: @code_gen }
        # end
    end

    # PATCH/PUT /code_gens/1
    # PATCH/PUT /code_gens/1.json
    def update
        respond_to do |format|
            if @code_gen.update(code_gen_params)
                format.html { redirect_to @code_gen, notice: 'Code gen was successfully updated.' }
                format.json { render :show, status: :ok, location: @code_gen }
            else
                format.html { render :edit }
                format.json { render json: @code_gen.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /code_gens/1
    # DELETE /code_gens/1.json
    def destroy
        @code_gen.destroy
        respond_to do |format|
            format.html { redirect_to code_gens_url, notice: 'Code gen was successfully destroyed.' }
            format.json { head :no_content }
        end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_gen
        @code_gen = CodeGen.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_gen_params
        params.require(:code_gen).permit(:table_name, :package_name, :project_name)
    end

end
